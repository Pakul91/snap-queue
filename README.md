navigate to the terraform directory and run:

```
> terraform init -backend-config config/<env>
> terraform plan -var-file=vars/<env>.tfvars --out=.tfplan
> terraform apply .tfplan
```

To destroy the infrastructure:

```
> terraform -destroy -var-file=vars/<env>.tfvars

```

# 📸 SnapQueue

SnapQueue is a full-stack serverless image processing application. Users upload images via a web-based SPA. The backend stores the image, processes it asynchronously (e.g., creates resized, grayscale, and thumbnail versions), and notifies the user in real-time via WebSocket once processing is complete. The frontend is hosted on S3 + CloudFront and communicates with the backend via REST and WebSocket APIs.

---

## 🚀 Backend Specification (AWS Serverless)

### ✈️ Services Used

- **API Gateway** (REST & WebSocket)
- **Lambda Functions**
- **S3** (uploads and processed buckets)
- **DynamoDB** (metadata and connection tracking)
- **SQS** (buffering)
- **CloudFront** (static frontend delivery)

### ⚙️ Architecture Components

#### REST API Endpoints

- `POST /upload-request`  
  Returns a pre-signed S3 URL and an `imageId` for uploading the image.

- `GET /image/{imageId}`  
  Retrieves an image with a specific ID.

- `GET /get-all-images`  
  Retrieves all images in the DB. _(Consider validating uploads to avoid displaying inappropriate content.)_

#### WebSocket API

- `$connect` / `$disconnect`  
  Tracks or removes active WebSocket connections.

- `registerImage`  
  Publishes the image upload information.

---

### 🗂 S3 Buckets

- `snapqueue-uploads` – Stores original user-uploaded images.
- `snapqueue-processed` – Stores resized, grayscale, and thumbnail versions.

### 📊 DynamoDB Tables

- `ImageMetadata`

  - Partition Key: `imageId`
  - Attributes: `status`, `uploadTimestamp`, `originalFilename`, `processedFiles`

- `WebSocketConnections`
  - Partition Key: `imageId`
  - Attributes: `connectionId`, `ttl`

### 🧠 Lambda Functions

- `GenerateUploadURLFunction`  
  Generates a pre-signed upload URL and records initial metadata.

- `ImageProcessingFunction`  
  Triggered by SQS messages from S3 event notifications.

  - Downloads the image
  - Processes and uploads results
  - Updates metadata
  - Sends message via WebSocket

- `RegisterImageFunction`  
  Links an `imageId` to a WebSocket `connectionId`.

- `ConnectionHandler`  
  Handles `$connect` and `$disconnect` lifecycle events.

- `GetStatusFunction` _(optional fallback)_  
  Returns metadata and URLs for a given `imageId`.

---

## 🌐 Frontend Specification (SPA)

### 🏗️ Hosting & Stack

- Hosted on **S3** with **CloudFront CDN**
- Built with **React**

### 🔧 Core Functionality

#### Image Upload Flow

1. User selects an image.
2. Client requests a pre-signed URL via REST API.
3. Uploads image directly to S3.

#### Real-Time Feedback

- Establishes a WebSocket connection to API Gateway.
- Sends `{ action: 'registerImage', imageId }`.
- Receives a push update when processing is complete.

#### Image Display

- Shows thumbnail, resized, and grayscale versions.
- Handles error/timeout with fallback polling via `GET /image/{imageId}`.

### 📄 Pages / Views

- **Home Page**: Upload form, preview area, processing status.
- **Gallery (optional)**: View previously processed images.

---

## 📚 Suggested Libraries

- **Axios** or **Fetch** for REST calls
- **Native WebSocket** or **Socket.IO** (with fallback wrapper)
- **Sharp** for local image processing parity

---

## 🔄 Flow Summary

```plaintext
1. SPA loads, connects to WebSocket
2. User requests pre-signed S3 URL
3. Image is uploaded to 'snapqueue-uploads' bucket
4. S3 triggers event → message sent to SQS
5. Lambda processes message from SQS
6. Lambda downloads, processes, and uploads to 'snapqueue-processed'
7. S3 triggers second SQS event (optional)
8. Lambda updates DynamoDB with metadata
9. Lambda sends WebSocket message to client
10. Client fetches and displays processed image
```
