"use client"
import { useEffect, useState } from "react";
import { parseEther } from "viem";
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth/useScaffoldWriteContract";
import { pinata } from "~~/utils/scaffold-eth/config";

function App() {
  const [selectedFile, setSelectedFile]= useState<File | null>(null);
  const [url, setUrl] = useState<string>("");
  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract("NFTCollection");

  const changeHandler = (event: React.ChangeEvent<HTMLInputElement>) => {

    if (!event.target?.files?.[0]) return;
    setSelectedFile(event.target?.files?.[0]);
  };

  const handleSubmission = async () => {
    if (!selectedFile) return;
    try {
      const upload = await pinata.upload.file(selectedFile)
      console.log(upload);

      const ipfsUrl = await pinata.gateways.convert(upload.IpfsHash)
      setUrl(ipfsUrl)
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    const mintNFT = async () => {
        try {
            const response = await writeYourContractAsync({
              functionName: "safeMint",
              args: ["0x1356C31E0485ce38C47DbF3C8f5a168cE0EA4413", url]
            });
            console.log("Minted NFT:", response);

          } catch (e) {
            console.error("Error setting greeting:", e);
          }
    }
    if (url) {
      mintNFT();
    }
  },[url])

//   useEffect(() => {
//     const setInitialUrl = async () => {
//     const url = await pinata.gateways.convert("QmZYJUuwXKLzkbHMEJeLRvbXijLt1TXmQVbcWKvsEYgkgZ");
//     setUrl(url);
//     }
//     setInitialUrl();
//   },[])

  return (
    <>
      <label className="form-label"> Choose File</label>
      <input
        type="file"
        onChange={changeHandler}
      />
      <button onClick={handleSubmission}>Submit</button>
      {url && (
        <img
          src={url}
          alt="uploaded image"
        />
      )}
    </>
  );
}

export default App;


