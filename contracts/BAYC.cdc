import NonFungibleToken from 0x01
pub contract BAYC: NonFungibleToken {

  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)


  pub resource NFT: NonFungibleToken.INFT {
    pub let id:UInt64

    init() {
      self.id = BAYC.totalSupply
      BAYC.totalSupply = BAYC.totalSupply + 1
    }
  }

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun deposit(token: @NonFungibleToken.NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This collection does not contain an NFT with that ID")
      return <- token
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?) ?? panic ("Nothing exists at this index")
    }

    pub fun borrowEntireNFT(id: UInt64): &NFT? {
      let refNFT = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT?
      return refNFT as! &NFT?
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
  }

  init() {
    self.totalSupply = 0
    emit ContractInitialized()

    self.account.save(<- create NFTMinter(), to: /storage/BAYC)
  }


}
