# 3D NFT Collection - Smart Contract per Stampe 3D

Progetto Foundry per creare una collezione NFT su Amoy (Polygon testnet) per stampe 3D. Il contratto permette a chiunque di mintare NFT con metadati personalizzati per rappresentare stampe 3D.

## Caratteristiche

- ✅ Minting pubblico - chiunque può mintare NFT
- ✅ Metadati personalizzati completi per stampe 3D
- ✅ Funzioni per leggere e aggiornare i metadati
- ✅ Supporto per file 3D (STL, OBJ, etc.)
- ✅ Informazioni tecniche di stampa (materiale, stampante, layer height, etc.)
- ✅ Compatibile con standard ERC721
- ✅ Deploy su Amoy testnet (Polygon)

## Struttura del Progetto

```
.
├── src/
│   └── ThreeDNFT.sol      # Smart contract principale
├── script/
│   └── Deploy.s.sol       # Script di deploy
├── test/
│   └── ThreeDNFT.t.sol    # Test del contratto
├── lib/                   # Dipendenze (OpenZeppelin, forge-std)
└── foundry.toml           # Configurazione Foundry
```

## Prerequisiti

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (opzionale, per tool di sviluppo)
- Wallet con MATIC su Amoy testnet

## Installazione

```bash
# Clona il repository
git clone https://github.com/FAFDA3/3d-nft.git
cd 3d-nft

# Installa le dipendenze
forge install
```

## Configurazione

Crea un file `.env` nella root del progetto:

```env
PRIVATE_KEY=your_private_key_here
AMOY_ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

**⚠️ IMPORTANTE**: Non committare mai il file `.env` con la tua chiave privata!

## Build

```bash
forge build
```

## Test

```bash
# Esegui tutti i test
forge test

# Esegui test con output verboso
forge test -vvv

# Esegui un test specifico
forge test --match-test test_MintSimple
```

## Deploy su Amoy

### 1. Ottieni MATIC di test

Vai su [Polygon Faucet](https://faucet.polygon.technology/) e richiedi MATIC per Amoy testnet.

### 2. Deploy del contratto

```bash
# Deploy su Amoy
forge script script/Deploy.s.sol:DeployScript --rpc-url amoy --broadcast --verify
```

### 3. Verifica il contratto

Dopo il deploy, il contratto sarà verificato automaticamente su Polygonscan Amoy.

## Utilizzo del Contratto

### Minting Semplice

```solidity
// Mint con dati essenziali
uint256 tokenId = nft.mintSimple(
    msg.sender,
    "Nome Stampa 3D",
    "https://ipfs.io/ipfs/QmModelFile",
    "https://ipfs.io/ipfs/QmImagePreview"
);
```

### Minting con Metadati Completi

```solidity
ThreeDNFT.NFTMetadata memory metadata = ThreeDNFT.NFTMetadata({
    name: "Vaso Decorativo",
    description: "Un vaso stampato in 3D con pattern geometrico",
    modelFileUrl: "https://ipfs.io/ipfs/QmSTLFile",
    imageUrl: "https://ipfs.io/ipfs/QmPreviewImage",
    material: "PLA",
    printer: "Prusa i3 MK3S",
    layerHeight: 200,  // in micron
    printTime: 120,    // in minuti
    color: "Red",
    timestamp: 0,      // verrà impostato automaticamente
    additionalData: '{"infill": 20, "supports": true, "temperature": 210}'
});

uint256 tokenId = nft.mint(msg.sender, metadata, "");
```

### Leggere i Metadati

```solidity
// Leggi tutti i metadati
ThreeDNFT.NFTMetadata memory metadata = nft.getMetadata(tokenId);

// Leggi solo i dati base
(string memory name, string memory desc, string memory modelUrl, string memory imageUrl) 
    = nft.getBasicMetadata(tokenId);

// Leggi i dettagli tecnici di stampa
(string memory material, string memory printer, uint256 layerHeight, uint256 printTime, string memory color)
    = nft.getPrintDetails(tokenId);
```

### Aggiornare i Metadati

```solidity
// Solo il proprietario può aggiornare i metadati
nft.updateMetadata(tokenId, newMetadata);
```

## Struttura Metadati

Ogni NFT contiene i seguenti metadati:

- **name**: Nome della stampa 3D
- **description**: Descrizione dettagliata
- **modelFileUrl**: URL del file 3D (STL, OBJ, etc.)
- **imageUrl**: URL dell'immagine di preview
- **material**: Materiale utilizzato (PLA, PETG, ABS, etc.)
- **printer**: Tipo di stampante
- **layerHeight**: Altezza del layer in micron
- **printTime**: Tempo di stampa in minuti
- **color**: Colore della stampa
- **timestamp**: Timestamp della creazione (automatico)
- **additionalData**: Dati aggiuntivi in formato JSON string

## Funzioni Principali

### Pubbliche

- `mint(address _to, NFTMetadata memory _metadata, string memory _tokenURI)` - Mint con metadati completi
- `mintSimple(address _to, string memory _name, string memory _modelFileUrl, string memory _imageUrl)` - Mint semplificato
- `getMetadata(uint256 _tokenId)` - Leggi tutti i metadati
- `getBasicMetadata(uint256 _tokenId)` - Leggi metadati base
- `getPrintDetails(uint256 _tokenId)` - Leggi dettagli tecnici
- `totalSupply()` - Numero totale di NFT mintati
- `updateMetadata(uint256 _tokenId, NFTMetadata memory _metadata)` - Aggiorna metadati (solo owner)

## Testnet

- **Amoy**: https://rpc-amoy.polygon.technology
- **Polygonscan Amoy**: https://amoy.polygonscan.com/

## Sicurezza

- Il contratto utilizza OpenZeppelin Contracts v5.5.0
- Minting pubblico senza restrizioni
- Solo il proprietario può aggiornare i metadati del proprio NFT
- Timestamp originale preservato durante gli aggiornamenti

## Licenza

MIT License

## Contribuire

Le pull request sono benvenute! Per cambiamenti importanti, apri prima una issue per discutere cosa vorresti cambiare.

## Supporto

Per domande o problemi, apri una issue su GitHub.
