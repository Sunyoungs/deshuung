const admin = require("firebase-admin");

// Firebase 서비스 계정 키 JSON 파일 로드
const serviceAccount = require("../serviceAccountKey.json"); // 실제 경로에 맞게 수정

// Firebase Admin 초기화
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

module.exports = { admin, db };
