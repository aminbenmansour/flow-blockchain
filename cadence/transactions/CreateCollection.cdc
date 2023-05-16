import BAYC from "../contracts/BAYC.cdc"
import NonFungibleToken from "../contracts/utilities/NonFungibleToken.cdc"

transaction {
    prepare(acct: AuthAccount) {
        acct.save(<-BAYC.createEmptyCollection(), to: /storage/Collection)
        acct.link<&BAYC.Collection{NonFungibleToken.CollectionPublic}>(/public/Collection, target: /storage/Collection)
    }

    execute {
    log("Stored a collecion for our BAYC")
    }
}