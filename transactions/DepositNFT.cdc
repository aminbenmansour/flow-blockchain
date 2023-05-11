import BAYC from 0x01
import NonFungibleToken from 0x01

transaction(recipient: Address) {
    prepare(acct: AuthAccount){
        let nftMinter = acct.borrow<&BAYC.NFTMinter>(from: /storage/Minter)!

        let publicReference = getAccount(recipient).getCapability(/public/Collection)
                                .borrow<&BAYC.Collection{NonFungibleToken.CollectionPublic}>()
                                ?? panic("This account does not have a collection")

        publicReference.deposit(token: <- nftMinter.createNFT())
    }

    execute {
        log("Stored newly minted NFT into collection")
    
    }

}