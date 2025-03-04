const express = require("express");
const axios = require("axios");
require("dotenv").config();
const NAVER_CLIENT_ID = "TLuHpwdwlC71BeKKodJ0";
const NAVER_CLIENT_SECRET = "A7mx4G0vVR";
const NAVER_API_URL = "https://openapi.naver.com/v1/search/local.json";
//위 secret 아마도 환경 변수 처리해야 하지 않을까

// 두 좌표 간 거리 계산 함수 (단위: km)
function getDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // 지구 반지름 (km)
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

// DT 매장 검색 API 엔드포인트 (GET 요청)
app.get("/now", async (req, res) => {
    try {
        const userLat = parseFloat(req.query.lat);
        const userLng = parseFloat(req.query.lng);

        // 요청한 좌표가 없으면 오류 반환
        if (isNaN(userLat) || isNaN(userLng)) {
            return res.status(400).json({ error: "잘못된 좌표 입력" });
        }

        // 네이버 지역 검색 API 요청
        const query = encodeURIComponent("DT"); // 검색 키워드
        const display = 5; // 최대 검색 결과 개수
        const sort = "random"; // 정렬 방식

        const url = `https://openapi.naver.com/v1/search/local.json?query=${query}&display=${display}&sort=${sort}`;
        
        const response = await axios.get(url, {
            headers: {
                "X-Naver-Client-Id": NAVER_CLIENT_ID,
                "X-Naver-Client-Secret": NAVER_CLIENT_SECRET
            }
        });

        const stores = response.data.items || [];

        // 반경 3km 이내의 매장 필터링
        const filteredStores = stores.filter(store => {
            const storeLat = parseFloat(store.mapy) / 10000000; // 좌표 변환
            const storeLng = parseFloat(store.mapx) / 10000000;
            return getDistance(userLat, userLng, storeLat, storeLng) <= 3;
        });

        res.json({ stores: filteredStores });
    } catch (error) {
        console.error("API 요청 실패:", error);
        res.status(500).json({ error: "서버 오류 발생" });
    }
});

app.get("/location", async (req, res) => {
    const query = "DT"; // 검색 키워드
    const display = 5; // 최대 검색 결과 개수

    try {
        const response = await axios.get(NAVER_API_URL, {
            headers: {
                "X-Naver-Client-Id": NAVER_CLIENT_ID,
                "X-Naver-Client-Secret": NAVER_CLIENT_SECRET
            },
            params: {
                query: query,
                display: display,
                start: 1,
                sort: "random" // 관련도순 정렬
            }
        });
        res.json(response.data);
    } catch (error) {
        console.error("Error fetching data from Naver API:", error);
        res.status(500).json({ message: "Failed to fetch data" });
    }
});


const stores = [
    { id: 1, name: "DT Store A", location: "Seoul", open: true },
    { id: 2, name: "DT Store B", location: "Busan", open: false },
    { id: 3, name: "DT Store C", location: "Incheon", open: true }
];

// DT 가게 목록 조회 API
app.get('/api/stores/list', (req, res) => {
    res.json({ success: true, data: stores });
});

// 특정 ID의 DT 가게 조회 API
app.get('/api/stores/:id', (req, res) => {
    const storeId = parseInt(req.params.id);
    const store = stores.find(s => s.id === storeId);
    
    if (store) {
        res.json({ success: true, data: store });
    } else {
        res.status(404).json({ success: false, message: "Store not found" });
    }
});

// Middleware
app.use(cors());
app.use(express.json());

// Sample menu data
const restaurantMenu = [
  {
    id: 1,
    name: "Signature Burger",
    price: 15000,
    category: "Main",
    description: "Angus beef patty with special sauce",
    isPopular: true
  },
  {
    id: 2,
    name: "Truffle Fries",
    price: 9000,
    category: "Side",
    description: "Crispy fries with truffle oil",
    isPopular: true
  },
  {
    id: 3,
    name: "Iced Americano",
    price: 5500,
    category: "Beverage",
    description: "Cold brew coffee"
  }
];

// Get full menu
app.get('/menulist', (req, res) => {
  res.json({
    success: true,
    data: restaurantMenu
  });
});

// Get menu item by ID
app.get('/menulist/:id', (req, res) => {
  const item = restaurantMenu.find(i => i.id === parseInt(req.params.id));
  if (!item) return res.status(404).json({ success: false, message: "Item not found" });
  res.json({ success: true, data: item });
});

// Order system variables
let orderIdCounter = 1;
const activeOrders = [];

// Essential middleware
app.use(cors());
app.use(express.json());

// 주문 처리 핵심 로직
app.post('/order', (req, res) => {
    const { items, customerInfo } = req.body;

    // 필수 파라미터 검증
    if (!items || !customerInfo) {
        return res.status(400).json({ error: 'Invalid request body' });
    }

    // 주문 품목 처리
    let total = 0;
    const processedItems = items.map(item => {
        // 실제 구현시 여기에 메뉴 정보 조회 로직 추가
        const itemPrice = 10000; // 임시 가격 값
        total += itemPrice * item.quantity;
        
        return {
            itemId: item.id,
            quantity: item.quantity,
            price: itemPrice
        };
    });

    // 주문 객체 생성
    const newOrder = {
        id: orderIdCounter++,
        items: processedItems,
        total,
        customer: customerInfo,
        status: 'RECEIVED',
        timestamp: new Date().toISOString()
    };

    activeOrders.push(newOrder);
    res.status(201).json(newOrder);
});

// 주문 상태 조회
app.get('/order/:orderId', (req, res) => {
    const order = activeOrders.find(o => o.id === parseInt(req.params.orderId));
    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json(order);
});
