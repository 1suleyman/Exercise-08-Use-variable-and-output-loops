# 🧱 Control, Nest, and Flex Your Loops in Bicep – Like a Cloud Chef 👨‍🍳

> **Bitesize Brain Snack 🍿**  
This lesson is for *you*, curious reader, to help you understand the logic behind the code in this repo — especially if you're learning Bicep and thinking *"what the heck is going on here?"*  
Also… this is future-me talking to present-me again (yes, hi 👋), just making sure I remember *why* I did things the way I did 😅

---

## ⏱️ Controlling Loop Execution: Bicep’s Pace Control

By default, Bicep’s loops are like a group of kids let loose on a trampoline — **everything happens at once** (in parallel), which is great for speed but not always what you want.

But what if you’re updating **App Services** and don’t want to reboot 10 production apps *all at once*? That’s where `@batchSize` comes in.

---

### 🏎️ Default: All at Once

```bicep
resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = [for i in range(1,3): {
  name: 'app${i}'
}]
```

All apps deploy together = **faster**, but also **riskier** in production.

---

### 🧃 Batch Mode: Deploy in Groups

```bicep
@batchSize(2)
resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = [for i in range(1,3): {
  name: 'app${i}'
}]
```

This deploys two at a time. Like a bouncer letting people into the club in pairs — **controlled chaos** 🎧

---

### 🐢 Slow and Steady: One at a Time

```bicep
@batchSize(1)
resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = [for i in range(1,3): {
  name: 'app${i}'
}]
```

This makes Bicep chill out and **deploy things sequentially**, like a polite queue at the bank 🏦

---

## 🧱 Loops Inside Resources: Set Properties with Style

Sometimes, it’s not about **how many resources**, but how many **pieces inside** a resource.

Say you’re building a virtual network with different **subnets** (like different rooms in a house 🏠). You can loop over those too:

```bicep
param subnetNames array = [
  'api'
  'worker'
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'teddybear'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [for (subnetName, i) in subnetNames: {
      name: subnetName
      properties: {
        addressPrefix: '10.0.${i}.0/24'
      }
    }]
  }
}
```

Each subnet gets its own name and IP range — tidy, repeatable, and easy to adjust. 🍽️

---

## 🧬 Nesting Loops: Loopception

When one loop isn't enough — **you loop inside another loop**. Like baking different flavors of cookies in every country’s bakery 🍪🌍

Let’s say you want to deploy a **virtual network** in each region, and each network needs **two subnets**:

```bicep
param locations array = [
  'westeurope'
  'eastus2'
  'eastasia'
]

var subnetCount = 2

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-05-01' = [for (location, i) in locations : {
  name: 'vnet-${location}'
  location: location
  properties: {
    addressSpace:{
      addressPrefixes:['10.${i}.0.0/16']
    }
    subnets: [for j in range(1, subnetCount): {
      name: 'subnet-${j}'
      properties: {
        addressPrefix: '10.${i}.${j}.0/24'
      }
    }]
  }
}]
```

So for each region, we get:
- A virtual network with a unique address space
- Two subnets with their own prefixes

Result? Clean, scalable network layout. Like giving each store in your franchise its own layout map.

---

## 📦 Variable Loops: Prep Your Ingredients First

Sometimes you don’t want to loop *in* the resource. You want to **build some data first**, then feed it into a resource. That’s where variable loops shine. ✨

```bicep
param addressPrefix string = '10.10.0.0/16'
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.0.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.1.0/24'
  }
]

var subnetsProperty = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}]
```

Then you plug that into your virtual network:

```bicep
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'teddybear'
  location: resourceGroup().location
  properties:{
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: subnetsProperty
  }
}
```

This is like pre-slicing your toppings before making the pizza. 🍕

---

## 🛬 Output Loops: Tell Me What You Deployed

Finally, after the Bicep magic is done, you probably want to **get some info back** — like the names and endpoints of the resources that were created.

```bicep
param locations array = [
  'westeurope'
  'eastus2'
  'eastasia'
]

resource storageAccounts 'Microsoft.Storage/storageAccounts@2023-05-01' = [for location in locations: {
  name: 'toy${uniqueString(resourceGroup().id, location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}]
```

To get those endpoints back, use an **output loop**:

```bicep
output storageEndpoints array = [for i in range(0, length(locations)): {
  name: storageAccounts[i].name
  location: storageAccounts[i].location
  blobEndpoint: storageAccounts[i].properties.primaryEndpoints.blob
  fileEndpoint: storageAccounts[i].properties.primaryEndpoints.file
}]
```

This is super useful for pipelines or anyone using the template — you hand back a list of “here’s what I built” 📋

> ⚠️ Don’t use outputs for secrets like passwords or access keys — outputs get logged!

---

## 🎯 TL;DR Recap

- 🧠 Use `@batchSize` to control how fast your loops deploy (all at once, in batches, or one by one)
- 🔁 Loops can go **inside resources** to build things like subnets
- 📦 Use **variables** to prep loop-based data before feeding it into a resource
- 🧬 **Nested loops** = loops inside loops = mega power
- 📤 Use **output loops** to return details of deployed stuff

---

So whether you’re deploying cloud networks for teddy bear factories 🧸 or just practicing Bicep like a pro, remember:

**Loops are your superpower.**  
And this README? It’s your trusty recap (for both you and me 😄)
