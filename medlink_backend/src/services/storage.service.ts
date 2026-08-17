import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { S3Client } from '@aws-sdk/client-s3';
import { Upload } from '@aws-sdk/lib-storage';

type StorageFolder = 'medical-records' | 'prescriptions' | 'avatars';

export class StorageService {
  static driver = process.env.STORAGE_DRIVER || 'local';

  static async uploadFile(params: {
    folder: StorageFolder;
    originalName: string;
    mimeType: string;
    buffer: Buffer;
  }): Promise<{ fileUrl: string; fileKey: string }> {
    if (this.driver === 's3') {
      return this.uploadToS3(params);
    }
    return this.uploadToLocal(params);
  }

  private static sanitizeName(name: string) {
    return name.replace(/[^a-zA-Z0-9._-]/g, '_');
  }

  private static async uploadToLocal(params: {
    folder: StorageFolder;
    originalName: string;
    mimeType: string;
    buffer: Buffer;
  }): Promise<{ fileUrl: string; fileKey: string }> {
    const ext = path.extname(params.originalName) || '';
    const safe = this.sanitizeName(path.basename(params.originalName, ext));
    const rand = crypto.randomBytes(8).toString('hex');
    const fileName = `${safe}_${rand}${ext}`;

    const dir = path.join(process.cwd(), 'uploads', params.folder);
    fs.mkdirSync(dir, { recursive: true });

    const fileKey = `${params.folder}/${fileName}`;
    const filePath = path.join(process.cwd(), 'uploads', fileKey);

    fs.writeFileSync(filePath, params.buffer);

    const baseUrl = process.env.PUBLIC_BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
    const fileUrl = `${baseUrl}/uploads/${fileKey}`;

    return { fileUrl, fileKey };
  }

  private static async uploadToS3(params: {
    folder: StorageFolder;
    originalName: string;
    mimeType: string;
    buffer: Buffer;
  }): Promise<{ fileUrl: string; fileKey: string }> {
    const region = process.env.AWS_REGION!;
    const bucket = process.env.AWS_S3_BUCKET!;
    if (!region || !bucket) throw new Error('S3 env vars missing');

    const ext = path.extname(params.originalName) || '';
    const safe = this.sanitizeName(path.basename(params.originalName, ext));
    const rand = crypto.randomBytes(8).toString('hex');
    const fileName = `${safe}_${rand}${ext}`;

    const fileKey = `${params.folder}/${fileName}`;

    const s3 = new S3Client({
      region,
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
      },
    });

    const uploader = new Upload({
      client: s3,
      params: {
        Bucket: bucket,
        Key: fileKey,
        Body: params.buffer,
        ContentType: params.mimeType,
      },
    });

    await uploader.done();

    // If bucket is public:
    const fileUrl = `https://${bucket}.s3.${region}.amazonaws.com/${fileKey}`;
    return { fileUrl, fileKey };
  }
}