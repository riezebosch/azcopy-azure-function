Access to both source and destination storage accounts needs to be configured for the `vnet/subnet` of the `functionapp` in the respective networkAcl's.

```bicep
  properties: {
    ...
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/default'
          action: 'Allow'
        }
      ]
```