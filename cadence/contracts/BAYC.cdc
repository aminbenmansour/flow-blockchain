import NonFungibleToken from "./utilities/NonFungibleToken.cdc"

pub contract BAYC: NonFungibleToken {

  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)


  pub resource NFT: NonFungibleToken.INFT {
    pub let id:UInt64
    pub let name: String

    init() {
      self.id = BAYC.totalSupply
      self.name = "Amine deploys NFT."
      BAYC.totalSupply = BAYC.totalSupply + 1
    }
  }

  pub resource interface MyCollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowEntireNFT(id: UInt64): &NFT
  }

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MyCollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let bayc <- token as! @NFT
      emit Deposit(id: bayc.id, to: self.owner!.address)
      
      self.ownedNFTs[bayc.id] <-! bayc
    }

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

    pub fun borrowEntireNFT(id: UInt64): &NFT {
      let refNFT = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT?
      return refNFT as! &NFT
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }

  }

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  pub resource NFTMinter {
    pub fun createNFT(): @NFT {
      return <- create NFT()
    }
    init(){}
  }

  init() {
    self.totalSupply = 0
    emit ContractInitialized()

    self.account.save(<- create NFTMinter(), to: /storage/BAYC)
  }
}
