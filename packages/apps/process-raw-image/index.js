import {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} from "@aws-sdk/client-s3";
import sharp from "sharp";

const s3Client = new S3Client({ region: process.env.AWS_REGION });

const RAW_IMAGE_BUCKET_NAME = process.env.RAW_IMAGE_BUCKET_NAME;
const PROCESSED_IMAGE_BUCKET_NAME = process.env.PROCESSED_IMAGE_BUCKET_NAME;

// 1. Download image from S3 using stream
async function downloadImageFromS3(key) {
  // Validate file type
  const imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "webp"];
  const extension = key.split(".").pop().toLowerCase();

  console.log("Received key:", key);
  console.log("Extracted extension:", extension);

  if (!imageExtensions.includes(extension)) {
    throw new Error(`Invalid file type: ${extension}`);
  }

  const command = new GetObjectCommand({
    Bucket: RAW_IMAGE_BUCKET_NAME,
    Key: key,
  });

  const response = await s3Client.send(command);

  // Convert stream to buffer
  const chunks = [];
  for await (const chunk of response.Body) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks);
}

// 2. Resize image to 150x150 using Sharp
async function resizeImage(imageBuffer) {
  return await sharp(imageBuffer)
    .resize(150, 150, { fit: "cover" })
    .jpeg({ quality: 90 })
    .toBuffer();
}

// 3. Upload image to S3
async function uploadImageToS3(key, imageBuffer) {
  const command = new PutObjectCommand({
    Bucket: PROCESSED_IMAGE_BUCKET_NAME,
    Key: key,
    Body: imageBuffer,
    ContentType: "image/jpeg",
  });

  return await s3Client.send(command);
}

// Main handler
export const handler = async (event) => {
  for (const record of event.Records) {
    try {
      const s3Event = JSON.parse(record.body);
      const key = s3Event.Records[0].s3.object.key;

      console.log("Processing image with key:", key);

      // 1. Download
      const originalImage = await downloadImageFromS3(key);

      console.log("Image downloaded successfully:");

      // 2. Resize
      const resizedImage = await resizeImage(originalImage);

      console.log("Image resized successfully:");

      // 3. Upload
      const newKey = key.replace(/\.[^/.]+$/, "_150x150.jpg");
      console.log("Uploading resized image to:", newKey);
      await uploadImageToS3(newKey, resizedImage);

      console.log("Successfully processed:", newKey);
    } catch (error) {
      console.error("Error processing image:", error);
    }
  }

  return { status: "Success" };
};
