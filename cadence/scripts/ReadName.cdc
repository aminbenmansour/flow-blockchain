import BAYC from "../contracts/BAYC.cdc"
import NonFungibleToken from "../contracts/utilities/NonFungibleToken.cdc"

pub fun main(account: Address, id: UInt64): String {
  let publicReference = getAccount(account).getCapability(/public/Collection)
                        .borrow<&BAYC.Collection{BAYC.MyCollectionPublic}>()
                        ?? panic("This account does not have a collection")

  return publicReference.borrowEntireNFT(id: id).name
}
