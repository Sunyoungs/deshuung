var express = require('express');
var router = express.Router();
const axios = require("axios");

//차량 위치 조회 



app.use(express.json());


import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import fetch from "node-fetch";

// Firebase Admin 초기화
initializeApp({ credential: applicationDefault() });
const db = getFirestore();

async function getVehicleLocation(providerId, vehicleId, idToken) {
    const url = `https://fleetengine.googleapis.com/v1/providers/${providerId}/vehicles/${vehicleId}`;
    
    const response = await fetch(url, {
        method: "GET",
        headers: {
            "Authorization": `Bearer ${idToken}`,
            "Content-Type": "application/json",
            "X-Goog-User-Project": "YOUR_PROJECT_ID"
        }
    });

    if (!response.ok) {
        throw new Error(`Error fetching vehicle location: ${response.statusText}`);
    }

    const data = await response.json();
    return {
        latitude: data.currentLocation.latitude,
        longitude: data.currentLocation.longitude
    };
}


// Fleet Engine API로 차량 생성
async function createVehicle(providerId, vehicleId, vehicleData, idToken) {
    const url = `https://fleetengine.googleapis.com/v1/providers/${providerId}/vehicles/${vehicleId}`;
    
    const response = await fetch(url, {
        method: "PUT", // Vehicle 생성은 PUT 요청
        headers: {
            "Authorization": `Bearer ${idToken}`,
            "Content-Type": "application/json",
            "X-Goog-User-Project": "YOUR_PROJECT_ID"
        },
        body: JSON.stringify(vehicleData)
    });

    if (!response.ok) {
        throw new Error(`Error creating vehicle: ${response.statusText}`);
    }

    return await response.json();
}

// Firestore에 저장
async function saveVehicleToFirestore(vehicleId, vehicleData) {
    const carRef = db.collection("cars").doc(vehicleId);
    await carRef.set(vehicleData);
    console.log(`🚗 차량 ${vehicleId} Firestore에 저장 완료`);
}

// 실행 함수
async function registerVehicle() {
    try {
        const providerId = "providers/YOUR_PROVIDER_ID";
        const vehicleId = "YOUR_VEHICLE_ID";
        const idToken = "YOUR_FIREBASE_ID_TOKEN"; // Firebase Auth에서 가져와야 함

        // Fleet Engine에 등록할 차량 정보
        const vehicleData = {
            vehicleState: "ONLINE",
            supportedTripTypes: ["EXCLUSIVE"],
            currentLocation: {
                latitude: 37.7749,
                longitude: -122.4194
            },
            vehicleType: { category: "AUTO" }
        };

        // Fleet Engine에 차량 등록
        const vehicle = await createVehicle(providerId, vehicleId, vehicleData, idToken);
        console.log("✅ Fleet Engine 등록 완료:", vehicle);

        // Firestore에 저장
        await saveVehicleToFirestore(vehicleId, vehicle);
    } catch (error) {
        console.error("❌ 오류 발생:", error);
    }
}

// 실행
registerVehicle();
