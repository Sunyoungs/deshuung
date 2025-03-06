var express = require('express');
var router = express.Router();
const axios = require("axios");

//차량 위치 조회 



app.use(express.json());

// 자동차 번호 조회 API 엔드포인트 (/cars/me 경로에서 GET 요청 가능하도록 변경)
app.get("/me", async (req, res) => {
    const { plateNumber } = req.query;

    if (!plateNumber) {
        return res.status(400).json({ error: "자동차 번호를 입력하세요." });
    }

    try {
        // 실제 자동차 정보 조회 API 호출
        const response = await axios.get(`https://apick.app/rest/get_car_info?plate=${plateNumber}`);
        
        // 응답 데이터를 클라이언트에게 전달
        return res.json(response.data);
    } catch (error) {
        console.error("자동차 정보 조회 오류:", error.message);
        return res.status(500).json({ error: "자동차 정보를 조회할 수 없습니다." });
    }
});


//차량 휴면 상태 
class Vehicle {
    constructor(plateNumber, status = "active") {
        this.plateNumber = plateNumber;
        this.status = status;
    }

    setDormant() {
        this.status = "dormant";
    }
}

class FleetManager {
    constructor() {
        this.vehicles = new Map();
        // 테스트용으로 초기 데이터 추가
        this.vehicles.set("123-ABC", new Vehicle("123-ABC"));
    }

    setVehicleDormant(plateNumber) {
        if (this.vehicles.has(plateNumber)) {
            this.vehicles.get(plateNumber).setDormant();
            return { message: `Vehicle ${plateNumber} is now dormant.` };
        } else {
            return { error: `Vehicle ${plateNumber} not found.` };
        }
    }
}

const fleet = new FleetManager();

// 차량 상태 'dormant'로 변경하는 API (POST /cars/del)
app.post("/del", (req, res) => {
    const { plateNumber } = req.body;
    if (!plateNumber) {
        return res.status(400).json({ error: "plateNumber is required." });
    }
    const result = fleet.setVehicleDormant(plateNumber);
    res.status(result.error ? 404 : 200).json(result);
});


//자동차 번호 인증 
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(cors());
app.post('/auth', (req, res) => {
    const { licensePlate } = req.body;
    
    if (!licensePlate) {
        return res.status(400).json({ success: false, message: "License plate is required" });
    }

    if (authorizedPlates.has(licensePlate.toUpperCase())) {
        return res.json({ success: true, message: "License plate is authorized" });
    } else {
        return res.status(403).json({ success: false, message: "License plate is not authorized" });
    }
});


//자동차 번호 등록 
// 임시 데이터 저장소
const carDatabase = [];

// 미들웨어 설정
app.use(bodyParser.json());

// 자동차 번호판 검증 함수
function validateCarNumber(carNumber) {
    const regex = /^[0-9]{2,3}[가-힣]{1}[0-9]{4}$/; // 예: 123가4567
    return regex.test(carNumber);
}

// 자동차 번호 등록 API (변경된 경로: /cars/register)
app.post('/register', (req, res) => {
    const { carNumber, owner } = req.body;
    
    if (!carNumber || !owner) {
        return res.status(400).json({ error: '자동차 번호와 소유자를 입력하세요.' });
    }
    
    if (!validateCarNumber(carNumber)) {
        return res.status(400).json({ error: '유효하지 않은 자동차 번호입니다.' });
    }
    
    // 중복 검사
    if (carDatabase.some(car => car.carNumber === carNumber)) {
        return res.status(409).json({ error: '이미 등록된 자동차 번호입니다.' });
    }
    
    // 등록
    carDatabase.push({ carNumber, owner });
    res.status(201).json({ message: '자동차 번호가 등록되었습니다.', carNumber, owner });
});

// 등록된 자동차 번호 조회 API
app.get('/', (req, res) => {
    res.json(carDatabase);
});

// 특정 자동차 번호 조회 API
app.get('/:carNumber', (req, res) => {
    const { carNumber } = req.params;
    const car = carDatabase.find(car => car.carNumber === carNumber);
    
    if (!car) {
        return res.status(404).json({ error: '자동차 번호가 등록되지 않았습니다.' });
    }
    
    res.json(car);
});





//아래 살펴보기 
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
