import { getAuth } from "firebase/auth";
import { getFirestore, doc, getDoc } from "firebase/firestore";

// Firestore 초기화
const db = getFirestore();

// Google Maps API를 사용한 거리 계산 함수 (Haversine 공식)
function getDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // 지구 반지름 (미터)
    const rad = Math.PI / 180;
    const dLat = (lat2 - lat1) * rad;
    const dLon = (lon2 - lon1) * rad;
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * rad) * Math.cos(lat2 * rad) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return R * c; // 미터 단위 반환
}

// Fleet Engine API에서 차량 위치 가져오기
async function getVehicleLocation(providerId, vehicleId, idToken) {
    const url = `https://fleetengine.googleapis.com/v1/providers/${providerId}/vehicles/${vehicleId}`;
    
    const response = await fetch(url, {
        method: "GET",
        headers: {
            "Authorization": `Bearer ${idToken}`,
            "Content-Type": "application/json",
            "X-Goog-User-Project": "deshuung"
        }
    });

    if (!response.ok) {
        throw new Error(`Error fetching vehicle location: ${response.statusText}`);
    }

    const data = await response.json();
    return { lat: data.currentLocation.latitude, lon: data.currentLocation.longitude };
}

// 현재 로그인한 사용자의 registeredCars 가져오기
async function getUserRegisteredCars() {
    const auth = getAuth();
    const user = auth.currentUser;
    if (!user) throw new Error("User not authenticated");

    const userRef = doc(db, "accounts", user.uid);
    const userDoc = await getDoc(userRef);

    if (!userDoc.exists()) throw new Error("User document not found");

    return userDoc.data().registeredCars || []; // 차량 ID 목록 반환
}

// 핸드폰 현재 위치 가져오기
function getDeviceLocation() {
    return new Promise((resolve, reject) => {
        if (!navigator.geolocation) {
            return reject(new Error("Geolocation is not supported by this browser"));
        }

        navigator.geolocation.getCurrentPosition(
            (position) => {
                resolve({ lat: position.coords.latitude, lon: position.coords.longitude });
            },
            (error) => {
                reject(new Error("Error getting device location: " + error.message));
            }
        );
    });
}

// 가장 가까운 차량 찾기
async function findNearestCar(providerId, idToken) {
    try {
        const registeredCars = await getUserRegisteredCars();
        if (registeredCars.length === 0) throw new Error("No registered cars found");

        const deviceLocation = await getDeviceLocation();
        let nearestCar = null;
        let minDistance = Infinity;

        for (const vehicleId of registeredCars) {
            const vehicleLocation = await getVehicleLocation(providerId, vehicleId, idToken);
            const distance = getDistance(
                vehicleLocation.lat, vehicleLocation.lon,
                deviceLocation.lat, deviceLocation.lon
            );

            if (distance < minDistance) {
                minDistance = distance;
                nearestCar = vehicleId;
            }
        }

        console.log(`🚗 가장 가까운 차량: ${nearestCar} (${minDistance.toFixed(2)}m)`);
        return nearestCar;
    } catch (error) {
        console.error("❌ Error finding nearest car:", error);
        return null;
    }
}



import { getAuth } from "firebase/auth";
const providerId = "providers/deshuung";
const idToken = "YOUR_FIREBASE_ID_TOKEN"; // Firebase Authentication에서 가져오기

// Google Maps API에서 두 좌표 간 거리 계산
function getDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // 지구 반지름 (미터)
    const rad = Math.PI / 180;
    const dLat = (lat2 - lat1) * rad;
    const dLon = (lon2 - lon1) * rad;
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * rad) * Math.cos(lat2 * rad) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return R * c; // 미터 단위 반환
}

// Fleet Engine API에서 차량 위치 가져오기
async function getVehicleLocation(providerId, vehicleId, idToken) {
    const url = `https://fleetengine.googleapis.com/v1/providers/${providerId}/vehicles/${vehicleId}`;
    
    const response = await fetch(url, {
        method: "GET",
        headers: {
            "Authorization": `Bearer ${idToken}`,
            "Content-Type": "application/json",
            "X-Goog-User-Project": "deshuung"
        }
    });

    if (!response.ok) {
        throw new Error(`Error fetching vehicle location: ${response.statusText}`);
    }

    const data = await response.json();
    return { lat: data.currentLocation.latitude, lon: data.currentLocation.longitude };
}

// 핸드폰 현재 위치 가져오기
function getDeviceLocation() {
    return new Promise((resolve, reject) => {
        if (!navigator.geolocation) {
            return reject(new Error("Geolocation is not supported by this browser"));
        }

        navigator.geolocation.getCurrentPosition(
            (position) => {
                resolve({ lat: position.coords.latitude, lon: position.coords.longitude });
            },
            (error) => {
                reject(new Error("Error getting device location: " + error.message));
            }
        );
    });
}

// Firebase ID Token 가져오기
async function getFirebaseIdToken() {
    const auth = getAuth();
    const user = auth.currentUser;
    if (user) {
        return await user.getIdToken();
    }
    throw new Error("User not authenticated");
}

// 거리 비교 및 경고창 띄우기
async function verifyDistance(providerId, vehicleId, threshold = 15) { // threshold: 경고 기준 거리 (미터)
    try {
        const idToken = await getFirebaseIdToken();
        const vehicleLocation = await getVehicleLocation(providerId, vehicleId, idToken);
        const deviceLocation = await getDeviceLocation();

        const distance = getDistance(
            vehicleLocation.lat, vehicleLocation.lon,
            deviceLocation.lat, deviceLocation.lon
        );

        console.log(`🚗 차량 위치: (${vehicleLocation.lat}, ${vehicleLocation.lon})`);
        console.log(`📱 핸드폰 위치: (${deviceLocation.lat}, ${deviceLocation.lon})`);
        console.log(`📏 차량과 핸드폰 간 거리: ${distance.toFixed(2)}m`);

        if (distance > threshold) {
            alert(`🚨 차량과 사용자의 거리가 ${distance.toFixed(2)}m입니다. 너무 멀리 떨어져 있습니다!`);
        }
    } catch (error) {
        console.error("Error verifying distance:", error);
    }
}

// 3분마다 실행
const providerId = "providers/deshuung";
findNearestCar(providerId, idToken).then((vehicleId) => {
    if (vehicleId) {
        console.log(`📡 선택된 차량 ID: ${vehicleId}`);
    } else {
        console.log("🚨 가까운 차량을 찾을 수 없음");
    }
});
setInterval(() => verifyDistance(providerId, vehicleId, 1000), 180000);
