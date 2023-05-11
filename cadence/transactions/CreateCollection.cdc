import BAYC from 0x01
import NonFungibleToken from 0x01

transaction {
    prepare(acct: AuthAccount) {
        acct.save(<-BAYC.createEmptyCollection(), to: /storage/Collection)
        acct.link<&BAYC.Collection{NonFungibleToken.CollectionPublic}>(/public/Collection, target: /storage/Collection)
    }

    execute {
    log("Stored a collecion for our BAYC")
    }
}