# Simple Datastore Library (SDL)
A simple no-nonsense library for interfacing with the Roblox Datastore API

## Installation
The installation process is simple, just copy the contents of the ```src\server\SDL\Datastore Manager.server.lua``` script into a new script in ServerScriptService. You can follow my naming convention or use your own, it doesn't matter. This is all you need to do, the rest of the library is unpacked by the Datastore Manager script. Do make sure you do not have any folder name 'SDL' in ServerStorage or the Player folder, as this will cause the library to not work.

## Usage
The library is very simple to use. All you need to do is invoke the bindable function (```ServerStorage\SDL\AddTrackedValue```) with the following parameters: the name of the tracked value, the data type (only ones ending in **Value** are supported), the default value (must match the data type). An example of this is shown below:

```lua
local AddTrackedValue = game:GetService("ServerStorage"):WaitForChild("SDL"):WaitForChild("AddTrackedValue")
AddTrackedValue:Invoke("Coins", "IntValue", 100)
```
**Note:** The default value is only used if the value does not exist in the datastore. If the value exists in the datastore, the value in the datastore will be used instead. Meaning that if you change the default value, it will not change the value in the datastore.

Once you have added a tracked value, you can read/write to it directly in the Player folder. ```playerfolder/SDL/ValueName``` is the path to the value. An example of this is shown below:

```lua
local coins = game:GetService("Players").Carbophile.SDL.Coins
print(coins.Value) -- Prints 100
coins.Value = 200
print(coins.Value) -- Prints 200
```
In this example 'Carbophile' is the player and 'Coins' is the tracked value.

## Responses and Errors
The library will return a response when you invoke the bindable function. The response will be with two values: the first value is a boolean indicating whether the operation was successful or not, the second value is the error message if the operation was not successful (similar to a pcall). An example of this is shown below:

```lua
local AddTrackedValue = game:GetService("ServerStorage"):WaitForChild("SDL"):WaitForChild("AddTrackedValue")
local success, err = AddTrackedValue:Invoke("Coins", "IntValue", 100)
if not success then
    warn(err)
end
```
**Note:** The error message will be nil if the operation was successful so avoid printing it if the operation was successful.

## Migration

### From traditional to SDL

This feature is planned for the beta release. Until then, this is not possible.

### From SDL to traditional

SDL stores it's data in a datastore called 'SDL' in a simple format. The key is the player's user ID and it is stored in the format of a dictionary: ```'ValueName' -> Value```.

## Planned Features

### Alpha

- [ ] Support for ordered datastores
- [ ] Support for versioning (datastores v2)

### Beta

- [ ] Automated migration from traditional to SDL


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
