import NonFungibleToken from "./utilities/NonFungibleToken.cdc"
import MetadataViews from "./utilities/MetadataViews.cdc"

pub contract BAYC: NonFungibleToken {

  pub var totalSupply: UInt64

  pub let CollectionStoragePath: StoragePath
  pub let CollectionPublicPath: PublicPath
  pub let MinterStoragePath: StoragePath

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)


  pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
    pub let id:UInt64

    pub let name: String
    pub let thumbnail: String
    pub let description: String

    pub fun getViews(): [Type] {
      return [
        Type<MetadataViews.Display>(),
        Type<String>(),
        Type<MetadataViews.Identity>()
      ]
    }

    pub fun resolveView(_ view: Type): AnyStruct? {
      switch view {
        case Type<MetadataViews.Display>():
          return MetadataViews.Display(
            name: self.name,
            description: self.description,
            thumbnail: self.thumbnail
        )
        case Type<String>():
          return self.name
        case Type<MetadataViews.Identity>():
          return MetadataViews.Identity(
            uuid: self.uuid
          )
      }

      return nil
  }
    init(
      id: UInt64,
      name: String,
      description: String,
      thumbnail: String,
    ) {
      self.id = id
      self.name = name
      self.thumbnail = thumbnail
      self.description = description
    }
  }

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
    // dictionary of NFT conforming tokens
    // NFT is a resource type with an `UInt64` ID field
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    init() {
      self.ownedNFTs <- {}
    }
    
    // deposit takes a NFT and adds it to the collections dictionary
    // and adds the ID to the id array
    pub fun deposit(token: @NonFungibleToken.NFT) {
      let token <- token as! @BAYC.NFT
      let id: UInt64 = token.id

      emit Deposit(id: token.id, to: self.owner?.address)
      // add the new token to the dictionary which removes the old one
      let oldToken <- self.ownedNFTs[id] <- token
      
      destroy oldToken
    }

    // withdraw removes an NFT from the collection and moves it to the caller
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This collection does not contain an NFT with that ID")
      emit Withdraw(id: withdrawID, from: self.owner?.address)
      return <- token
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?) ?? panic ("Nothing exists at this index")
    }

    pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
      
      let nft = &self.ownedNFTs[id] as &NonFungibleToken.NFT?
  
      if let exampleNFT = nft as? &BAYC.NFT {
        return exampleNFT
      }
  
  panic("Invalid NFT type")

    }

    destroy() {
      destroy self.ownedNFTs
    }

  }

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  // Resource that an admin or something similar would own to be
  // able to mint new NFTs
  //
  pub resource NFTMinter {
    // mintNFT mints a new NFT with a new ID
    // and deposit it in the recipients collection using their collection reference
    pub fun mintNFT(
        recipient: &{NonFungibleToken.CollectionPublic},
        name: String,
        description: String,
        thumbnail: String,
      ) {
        // create a new NFT
        var newNFT <- create NFT(
          id: BAYC.totalSupply,
          name: name,
          description: description,
          thumbnail: thumbnail,
        )
        // deposit it in the recipient's account using their reference
        recipient.deposit(token: <-newNFT)
        BAYC.totalSupply = BAYC.totalSupply + 1
      }
  }

  init() {
    // Initialize the total supply
        self.totalSupply = 0

        // Set the named paths
        self.CollectionStoragePath = /storage/BAYCCollection
        self.CollectionPublicPath = /public/BAYCCollection
        self.MinterStoragePath = /storage/BAYCMinter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&BAYC.Collection{NonFungibleToken.CollectionPublic}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
  }
}
