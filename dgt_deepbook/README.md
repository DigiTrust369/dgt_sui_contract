
# How to work with DGT vault

PACKAGE_ID=0xe733afcdbcd61f8a795342dfb3cf4ea8977b3426a0f1df7a2bd3c50d23d1c99c

BASE_COIN_TYPE=0xe733afcdbcd61f8a795342dfb3cf4ea8977b3426a0f1df7a2bd3c50d23d1c99c::dgt::DGT

QUOTE_COIN_TYPE=0x2::sui::SUI

SUI_FEE_COIN_ID=0x016b9a6e8e171665973eff12f701058ddb37c2dcaaf0e9616949b82d88521453

WBTC_TREASURY_CAP_ID=0x6109f11f58aad51a7f1ac9943a04d73b937ba6aca92287ff5e2e3f967d945ae7

ACCOUNT_ID1=0x4cc7eac61ace69d47b64b974b15d3dee7277e34abc57de69228106e393418dcd

POOL_ID=0xfd0debf5753bae5ac2975d21e57a27bb6a86f6cf6c4e5eb411e205c383f83a02

BASE_COIN_ID=0x016b9a6e8e171665973eff12f701058ddb37c2dcaaf0e9616949b82d88521453

ACCOUNT1_CAP_ID=0xca9f8d3697a2a33291cfa6ea0d2f58afa873d7533f5b49d73caa962d77c1a260

## Setup
- `PACKAGE_ID` - the id of the published package. The json path to it is `.objectChanges[].packageId`
- `ORIGINAL_UPGRADE_CAP_ID` - the upgrade cap id that we might need if we find ourselves in the situation when we need to upgrade the contract. Path: `.objectChanges[].objectId` where `.objectChanges[].objectType` is  `0x2::package::UpgradeCap`
- `SUI_FEE_COIN_ID` the id of the SUI coin that we are going to use to pay the fee for the pool creation. Take any from the output of this command: `sui client gas --json`
- `MANAGER_ID` - address of funding manager
- `CLOCK_OBJECT_ID` - the id of the `Clock` object, default to `0x6`
- `BASE_COIN_TYPE` - the type of the SUI coin, default to `0x2::sui::SUI`
- `ETF_COIN_TYPE` - the type of the ETF token, which can present number of owner in the 
- `ETF_TREASURY_CAP_ID` it's the treasury cap id that is needed for token mint operations. 

## Interact with the contract

### Create pool

Now we create a pool:
```
sui client call --package $PACKAGE_ID  --module book --function new_pool --type-args $BASE_COIN_TYPE $QUOTE_COIN_TYPE --args $SUI_FEE_COIN_ID --gas-budget 10000000000 --json
```