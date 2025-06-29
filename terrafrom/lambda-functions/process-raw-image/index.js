import {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} from "@aws-sdk/client-s3";
import sharp from "sharp";

const s3Client = new S3Client({ region: process.env.AWS_REGION });

// 1. Download image from S3 using stream
async function downloadImageFromS3(bucket, key) {
  // Validate file type
  const imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"];
  const extension = key.split(".").pop().toLowerCase();

  if (!imageExtensions.includes(extension)) {
    throw new Error(`Invalid file type: ${extension}`);
  }

  const command = new GetObjectCommand({
    Bucket: bucket,
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
async function uploadImageToS3(bucket, key, imageBuffer) {
  const command = new PutObjectCommand({
    Bucket: bucket,
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
      const bucket = s3Event.Records[0].s3.bucket.name;
      const key = decodeURIComponent(
        s3Event.Records[0].s3.object.key.replace(/\+/g, " ")
      );

      console.log("Processing:", { bucket, key });

      // 1. Download
      const originalImage = await downloadImageFromS3(bucket, key);

      // 2. Resize
      const resizedImage = await resizeImage(originalImage);

      // 3. Upload
      const newKey = key.replace(/\.[^/.]+$/, "_150x150.jpg");
      await uploadImageToS3(bucket, newKey, resizedImage);

      console.log("Successfully processed:", newKey);
    } catch (error) {
      console.error("Error processing image:", error);
    }
  }

  return { status: "Success" };
};
