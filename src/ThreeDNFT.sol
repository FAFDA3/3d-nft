// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ThreeDNFT
 * @dev Smart contract per NFT di stampe 3D su Amoy (Polygon testnet)
 * Permette a chiunque di mintare NFT con metadati personalizzati
 */
contract ThreeDNFT is ERC721URIStorage, Ownable {
    using Strings for uint256;

    // Contatore per i token ID
    uint256 private _tokenIdCounter;

    // Struttura per i metadati personalizzati di ogni NFT
    struct NFTMetadata {
        string name;                    // Nome della stampa 3D
        string description;             // Descrizione della stampa
        string modelFileUrl;            // URL del file 3D (STL, OBJ, etc.)
        string imageUrl;                // URL dell'immagine di preview
        string material;                // Materiale utilizzato per la stampa
        string printer;                 // Tipo di stampante utilizzata
        uint256 layerHeight;            // Altezza layer in micron
        uint256 printTime;               // Tempo di stampa in minuti
        string color;                   // Colore della stampa
        uint256 timestamp;               // Timestamp della creazione
        string additionalData;          // Dati aggiuntivi in formato JSON string
    }

    // Mapping tokenId => metadati personalizzati
    mapping(uint256 => NFTMetadata) public nftMetadata;

    // Eventi
    event NFTMinted(
        uint256 indexed tokenId,
        address indexed to,
        string name,
        string modelFileUrl
    );

    event MetadataUpdated(
        uint256 indexed tokenId,
        string name,
        string modelFileUrl
    );

    /**
     * @dev Costruttore del contratto
     * @param _name Nome della collezione NFT
     * @param _symbol Simbolo della collezione NFT
     */
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        _tokenIdCounter = 0;
    }

    /**
     * @dev Funzione pubblica per mintare un nuovo NFT con metadati personalizzati
     * @param _to Indirizzo che riceverà l'NFT
     * @param _metadata Struttura con tutti i metadati della stampa 3D
     * @param _tokenURI URI dei metadati standard (opzionale, può essere vuoto)
     * @return tokenId L'ID del token appena creato
     */
    function mint(
        address _to,
        NFTMetadata memory _metadata,
        string memory _tokenURI
    ) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        // Mint dell'NFT
        _safeMint(_to, tokenId);

        // Salva i metadati personalizzati
        _metadata.timestamp = block.timestamp;
        nftMetadata[tokenId] = _metadata;

        // Imposta l'URI se fornito
        if (bytes(_tokenURI).length > 0) {
            _setTokenURI(tokenId, _tokenURI);
        }

        emit NFTMinted(tokenId, _to, _metadata.name, _metadata.modelFileUrl);

        return tokenId;
    }

    /**
     * @dev Funzione semplificata per mintare con solo i dati essenziali
     * @param _to Indirizzo che riceverà l'NFT
     * @param _name Nome della stampa 3D
     * @param _modelFileUrl URL del file 3D
     * @param _imageUrl URL dell'immagine di preview
     * @return tokenId L'ID del token appena creato
     */
    function mintSimple(
        address _to,
        string memory _name,
        string memory _modelFileUrl,
        string memory _imageUrl
    ) public returns (uint256) {
        NFTMetadata memory metadata = NFTMetadata({
            name: _name,
            description: "",
            modelFileUrl: _modelFileUrl,
            imageUrl: _imageUrl,
            material: "",
            printer: "",
            layerHeight: 0,
            printTime: 0,
            color: "",
            timestamp: block.timestamp,
            additionalData: ""
        });

        return mint(_to, metadata, "");
    }

    /**
     * @dev Legge tutti i metadati di un NFT
     * @param _tokenId ID del token
     * @return metadata Struttura completa dei metadati
     */
    function getMetadata(uint256 _tokenId) public view returns (NFTMetadata memory) {
        require(_ownerOf(_tokenId) != address(0), "Token does not exist");
        return nftMetadata[_tokenId];
    }

    /**
     * @dev Legge un campo specifico dei metadati
     * @param _tokenId ID del token
     * @return name Nome della stampa 3D
     * @return description Descrizione
     * @return modelFileUrl URL del file 3D
     * @return imageUrl URL dell'immagine
     */
    function getBasicMetadata(uint256 _tokenId) 
        public 
        view 
        returns (
            string memory name,
            string memory description,
            string memory modelFileUrl,
            string memory imageUrl
        ) 
    {
        require(_ownerOf(_tokenId) != address(0), "Token does not exist");
        NFTMetadata memory metadata = nftMetadata[_tokenId];
        return (metadata.name, metadata.description, metadata.modelFileUrl, metadata.imageUrl);
    }

    /**
     * @dev Legge i dettagli tecnici della stampa
     * @param _tokenId ID del token
     * @return material Materiale utilizzato
     * @return printer Tipo di stampante
     * @return layerHeight Altezza layer
     * @return printTime Tempo di stampa
     * @return color Colore
     */
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
    {
        require(_ownerOf(_tokenId) != address(0), "Token does not exist");
        NFTMetadata memory metadata = nftMetadata[_tokenId];
        return (
            metadata.material,
            metadata.printer,
            metadata.layerHeight,
            metadata.printTime,
            metadata.color
        );
    }

    /**
     * @dev Aggiorna i metadati di un NFT (solo il proprietario)
     * @param _tokenId ID del token
     * @param _metadata Nuovi metadati
     */
    function updateMetadata(uint256 _tokenId, NFTMetadata memory _metadata) public {
        require(_ownerOf(_tokenId) == msg.sender, "Not the owner");
        _metadata.timestamp = nftMetadata[_tokenId].timestamp; // Mantieni il timestamp originale
        nftMetadata[_tokenId] = _metadata;
        emit MetadataUpdated(_tokenId, _metadata.name, _metadata.modelFileUrl);
    }

    /**
     * @dev Restituisce il numero totale di NFT mintati
     * @return totalSupply Numero totale di token
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    /**
     * @dev Override della funzione _baseURI per supportare IPFS o altri servizi
     * @return baseURI URI di base per i token
     */
    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }
}

