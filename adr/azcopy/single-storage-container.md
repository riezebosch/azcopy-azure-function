azcopy supports out of the box only synchronizing a single storage container. 

For it to synchronize _all_ containers inside a storage account, you'll need to query the 
containers first and then setup sync jobs for each container individually.

There's been some work on creating a [durable function](https://docs.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-overview?tabs=powershell) to first list all containers and then fanout into activities for each container.