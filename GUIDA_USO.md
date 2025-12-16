# Guida all'Uso dello Smart Contract ThreeDNFT

## Informazioni del Contratto

- **Indirizzo**: `0x123d3371C3481394a6BddfDFB85BE31D6C182cEE`
- **Network**: Amoy (Polygon Testnet)
- **Chain ID**: 80002
- **Explorer**: https://amoy.polygonscan.com/address/0x123d3371C3481394a6BddfDFB85BE31D6C182cEE
- **Nome Collezione**: 3D Print NFT Collection
- **Simbolo**: 3DPNFT

## Funzionalità Principali

Lo smart contract permette a **chiunque** di mintare NFT con metadati personalizzati per rappresentare stampe 3D.

## Come Mintare un NFT

### Metodo 1: Minting Semplice

Il metodo più veloce per mintare un NFT con solo i dati essenziali:

```solidity
mintSimple(
    address _to,              // Indirizzo che riceverà l'NFT
    string _name,              // Nome della stampa 3D
    string _modelFileUrl,     // URL del file 3D (es. IPFS)
    string _imageUrl          // URL dell'immagine di preview
)
```

**Esempio:**
```solidity
nft.mintSimple(
    0xTuoIndirizzo,
    "Vaso Decorativo",
    "https://ipfs.io/ipfs/QmModelFile123",
    "https://ipfs.io/ipfs/QmImagePreview123"
);
```

### Metodo 2: Minting con Metadati Completi

Per mintare con tutti i dettagli tecnici della stampa:

```solidity
mint(
    address _to,
    NFTMetadata memory _metadata,
    string memory _tokenURI  // Opzionale, può essere vuoto ""
)
```

**Struttura NFTMetadata:**
```solidity
struct NFTMetadata {
    string name;                    // Nome della stampa 3D
    string description;             // Descrizione dettagliata
    string modelFileUrl;            // URL del file 3D (STL, OBJ, etc.)
    string imageUrl;                // URL dell'immagine di preview
    string material;                // Materiale (PLA, PETG, ABS, etc.)
    string printer;                 // Tipo di stampante
    uint256 layerHeight;            // Altezza layer in micron
    uint256 printTime;              // Tempo di stampa in minuti
    string color;                   // Colore della stampa
    uint256 timestamp;               // Lasciare a 0, viene impostato automaticamente
    string additionalData;          // Dati aggiuntivi in formato JSON string
}
```

**Esempio completo:**
```solidity
ThreeDNFT.NFTMetadata memory metadata = ThreeDNFT.NFTMetadata({
    name: "Vaso Decorativo",
    description: "Un vaso stampato in 3D con pattern geometrico complesso",
    modelFileUrl: "https://ipfs.io/ipfs/QmSTLFile123",
    imageUrl: "https://ipfs.io/ipfs/QmPreviewImage123",
    material: "PLA",
    printer: "Prusa i3 MK3S",
    layerHeight: 200,  // 0.2mm in micron
    printTime: 120,    // 2 ore in minuti
    color: "Red",
    timestamp: 0,      // Verrà impostato automaticamente
    additionalData: '{"infill": 20, "supports": true, "temperature": 210, "bedTemp": 60}'
});

nft.mint(msg.sender, metadata, "");
```

## Come Leggere i Metadati

### Leggere Tutti i Metadati

```solidity
function getMetadata(uint256 _tokenId) public view returns (NFTMetadata memory)
```

**Esempio:**
```solidity
ThreeDNFT.NFTMetadata memory metadata = nft.getMetadata(0);
console.log("Nome:", metadata.name);
console.log("Materiale:", metadata.material);
console.log("File 3D:", metadata.modelFileUrl);
```

### Leggere Solo i Dati Base

```solidity
function getBasicMetadata(uint256 _tokenId) 
    public 
    view 
    returns (
        string memory name,
        string memory description,
        string memory modelFileUrl,
        string memory imageUrl
    )
```

**Esempio:**
```solidity
(string memory name, string memory desc, string memory modelUrl, string memory imageUrl) 
    = nft.getBasicMetadata(0);
```

### Leggere i Dettagli Tecnici di Stampa

```solidity
function getPrintDetails(uint256 _tokenId)
    public
    view
    returns (
        string memory material,
        string memory printer,
        uint256 layerHeight,
        uint256 printTime,
        string memory color
    )
```

**Esempio:**
```solidity
(string memory material, string memory printer, uint256 layerHeight, uint256 printTime, string memory color)
    = nft.getPrintDetails(0);
```

## Come Aggiornare i Metadati

Solo il **proprietario** dell'NFT può aggiornare i suoi metadati:

```solidity
function updateMetadata(uint256 _tokenId, NFTMetadata memory _metadata) public
```

**Esempio:**
```solidity
// Crea nuovi metadati
ThreeDNFT.NFTMetadata memory updatedMetadata = ThreeDNFT.NFTMetadata({
    name: "Vaso Decorativo V2",
    description: "Versione migliorata",
    modelFileUrl: "https://ipfs.io/ipfs/QmNewModel",
    imageUrl: "https://ipfs.io/ipfs/QmNewImage",
    material: "PETG",  // Cambiato da PLA a PETG
    printer: "Ender 3",
    layerHeight: 150,
    printTime: 90,
    color: "Blue",
    timestamp: 0,  // Il timestamp originale viene preservato
    additionalData: '{"infill": 30}'
});

// Aggiorna (solo se sei il proprietario)
nft.updateMetadata(0, updatedMetadata);
```

**Nota**: Il timestamp originale viene sempre preservato durante l'aggiornamento.

## Funzioni Utili

### Controllare il Numero Totale di NFT Mintati

```solidity
uint256 total = nft.totalSupply();
```

### Controllare il Proprietario di un NFT

```solidity
address owner = nft.ownerOf(tokenId);
```

### Controllare il Balance di NFT di un Indirizzo

```solidity
uint256 balance = nft.balanceOf(address);
```

## Utilizzo con Foundry

### Interagire con il Contratto da Script

Crea un file `script/Interact.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {ThreeDNFT} from "../src/ThreeDNFT.sol";

contract InteractScript is Script {
    ThreeDNFT nft = ThreeDNFT(0x123d3371C3481394a6BddfDFB85BE31D6C182cEE);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Mint un NFT semplice
        uint256 tokenId = nft.mintSimple(
            msg.sender,
            "Test Print",
            "https://ipfs.io/ipfs/QmTest123",
            "https://ipfs.io/ipfs/QmImage123"
        );

        console.log("NFT mintato con ID:", tokenId);

        // Leggi i metadati
        ThreeDNFT.NFTMetadata memory metadata = nft.getMetadata(tokenId);
        console.log("Nome:", metadata.name);
        console.log("Total supply:", nft.totalSupply());

        vm.stopBroadcast();
    }
}
```

Esegui con:
```bash
forge script script/Interact.s.sol:InteractScript --rpc-url amoy --broadcast
```

## Utilizzo con Web3.js / Ethers.js

### Minting da JavaScript

```javascript
const { ethers } = require("ethers");

// Configurazione
const provider = new ethers.JsonRpcProvider("https://rpc-amoy.polygon.technology");
const wallet = new ethers.Wallet("YOUR_PRIVATE_KEY", provider);
const contractAddress = "0x123d3371C3481394a6BddfDFB85BE31D6C182cEE";

// ABI del contratto (solo le funzioni necessarie)
const abi = [
    "function mintSimple(address _to, string memory _name, string memory _modelFileUrl, string memory _imageUrl) external returns (uint256)",
    "function getMetadata(uint256 _tokenId) public view returns (tuple(string name, string description, string modelFileUrl, string imageUrl, string material, string printer, uint256 layerHeight, uint256 printTime, string color, uint256 timestamp, string additionalData))",
    "function totalSupply() public view returns (uint256)"
];

const contract = new ethers.Contract(contractAddress, abi, wallet);

// Mint un NFT
async function mintNFT() {
    const tx = await contract.mintSimple(
        wallet.address,
        "Vaso Decorativo",
        "https://ipfs.io/ipfs/QmModel123",
        "https://ipfs.io/ipfs/QmImage123"
    );
    
    const receipt = await tx.wait();
    console.log("NFT mintato! Hash:", receipt.hash);
    
    // Leggi il total supply
    const total = await contract.totalSupply();
    console.log("Total NFT:", total.toString());
}

mintNFT();
```

## Utilizzo con Remix

1. Vai su https://remix.ethereum.org
2. Crea un nuovo file `ThreeDNFT.sol` e incolla il codice del contratto
3. Compila il contratto
4. Nella sezione "Deploy & Run":
   - Seleziona "Injected Provider" come ambiente
   - Assicurati di essere connesso ad Amoy
   - Inserisci l'indirizzo del contratto: `0x123d3371C3481394a6BddfDFB85BE31D6C182cEE`
   - Clicca su "At Address"
5. Ora puoi interagire con tutte le funzioni del contratto

## Struttura dei Metadati

Ogni NFT contiene:

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| `name` | string | Nome della stampa 3D |
| `description` | string | Descrizione dettagliata |
| `modelFileUrl` | string | URL del file 3D (STL, OBJ, etc.) |
| `imageUrl` | string | URL dell'immagine di preview |
| `material` | string | Materiale utilizzato (PLA, PETG, ABS, etc.) |
| `printer` | string | Tipo di stampante |
| `layerHeight` | uint256 | Altezza del layer in micron (es. 200 = 0.2mm) |
| `printTime` | uint256 | Tempo di stampa in minuti |
| `color` | string | Colore della stampa |
| `timestamp` | uint256 | Timestamp della creazione (automatico) |
| `additionalData` | string | Dati aggiuntivi in formato JSON string |

## Esempi di additionalData

Il campo `additionalData` può contenere qualsiasi JSON string con informazioni aggiuntive:

```json
{
    "infill": 20,
    "supports": true,
    "temperature": 210,
    "bedTemp": 60,
    "speed": 50,
    "nozzle": 0.4,
    "filamentBrand": "Polymaker"
}
```

## Best Practices

1. **Usa IPFS per i file**: Carica i file 3D e le immagini su IPFS per garantire decentralizzazione
2. **Valida gli URL**: Assicurati che gli URL siano accessibili e permanenti
3. **Formato JSON**: Usa un formato JSON valido per `additionalData`
4. **Layer Height**: Converti i millimetri in micron (es. 0.2mm = 200 micron)
5. **Timestamp**: Lascia sempre `timestamp` a 0 durante il mint, viene impostato automaticamente

## Costi del Gas

- **Minting semplice**: ~200,000 gas
- **Minting completo**: ~370,000 gas
- **Lettura metadati**: Gratis (view function)
- **Aggiornamento metadati**: ~400,000 gas

## Supporto

Per domande o problemi:
- GitHub: https://github.com/FAFDA3/3d-nft
- Polygonscan: https://amoy.polygonscan.com/address/0x123d3371C3481394a6BddfDFB85BE31D6C182cEE

## Note Importanti

- Il contratto è deployato su **Amoy testnet**, non sulla mainnet di Polygon
- Chiunque può mintare NFT senza restrizioni
- Solo il proprietario può aggiornare i metadati del proprio NFT
- Il timestamp originale viene sempre preservato durante gli aggiornamenti
- Non c'è limite al numero di NFT che possono essere mintati

