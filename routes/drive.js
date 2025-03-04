require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const twilio = require("twilio");
const nodemailer = require("nodemailer");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const TWILIO_PHONE_NUMBER = process.env.TWILIO_PHONE_NUMBER;
const RECEIVER_PHONE_NUMBER = process.env.RECEIVER_PHONE_NUMBER;
const EMAIL_USER = process.env.EMAIL_USER;
const EMAIL_PASS = process.env.EMAIL_PASS;
const RECEIVER_EMAIL = process.env.RECEIVER_EMAIL;

// Twilio SMS 설정
const twilioClient = twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);

// Nodemailer 이메일 설정
const transporter = nodemailer.createTransport({
    service: "Gmail",
    auth: {
        user: EMAIL_USER,
        pass: EMAIL_PASS
    }
});

// 거리 계산 함수 (Haversine 공식을 이용)
function getDistance(lat1, lon1, lat2, lon2) {
    const R = 6371000; // 지구 반경 (미터)
    const toRad = (angle) => (angle * Math.PI) / 180;

    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRad(lat1)) *
            Math.cos(toRad(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // 미터 단위 거리 반환
}

app.post("/send-alert", async (req, res) => {
    const { vehicleId, userLat, userLng, vehicleLat, vehicleLng } = req.body;
    
    const distance = getDistance(userLat, userLng, vehicleLat, vehicleLng);
    const threshold = 8; // 8m 오차 범위

    if (distance <= threshold) {
        return res.send("🚗 차량이 정상 범위 내에 있습니다.");
    }

    const message = `🚨 차량(${vehicleId})이 ${distance.toFixed(2)}M 이상 떨어져 있습니다! \n사용자 위치: (${userLat}, ${userLng})\n차량 위치: (${vehicleLat}, ${vehicleLng})`;

    try {
        // SMS 전송
        await twilioClient.messages.create({
            body: message,
            from: TWILIO_PHONE_NUMBER,
            to: RECEIVER_PHONE_NUMBER
        });

        // 이메일 전송
        await transporter.sendMail({
            from: EMAIL_USER,
            to: RECEIVER_EMAIL,
            subject: "🚨 차량 거리 경고",
            text: message
        });

        res.send("🚨 경고 알림 전송 완료!");
    } catch (error) {
        console.error("알림 전송 오류:", error);
        res.status(500).send("알림 전송 실패");
    }
});

app.get("/drive/post", (req, res) => {
    res.send("GET 요청이 허용되었습니다.");
});
