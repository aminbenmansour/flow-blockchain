import BAYC from "../contracts/BAYC.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {

    prepare(signer: AuthAccount) {
        // Return early if the account already has a collection
        if signer.borrow<&BAYC.Collection>(from: BAYC.CollectionStoragePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- BAYC.createEmptyCollection()

        // save it to the account
        signer.save(<-collection, to: BAYC.CollectionStoragePath)

        // create a public capability for the collection
        signer.link<&{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
            BAYC.CollectionPublicPath,
            target: BAYC.CollectionStoragePath
        )
    }

    execute {
      log("Setup account")
    }
}