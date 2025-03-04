const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');


// JSON 요청 본문을 파싱
app.use(bodyParser.json());

// 임시 카드 저장소 (실제 서비스에서는 데이터베이스 사용)
const registeredCards = [];

// JWT 인증 미들웨어: 요청 헤더의 토큰을 확인하여 인증된 사용자만 접근 가능하게 함
const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: '인증 토큰이 없습니다.' });
  }
  const token = authHeader.split(' ')[1];
  try {
    // JWT 검증; 실제 환경에서는 비밀 키를 환경 변수로 관리하세요.
    const decoded = jwt.verify(token, 'YOUR_SECRET_KEY');
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: '유효하지 않은 토큰입니다.' });
  }
};

// 카드 정보를 등록하는 엔드포인트 (POST /pay/register)
app.post('/pay/register', authenticate, (req, res) => {
  const { cardNumber, expiry, cvv, cardHolder } = req.body;

  // 필수 입력값 검증
  if (!cardNumber || !expiry || !cvv || !cardHolder) {
    return res.status(400).json({ error: '모든 카드 정보를 입력하세요.' });
  }

  // 카드 정보 객체 생성 (보안상 실제 서비스에서는 암호화 필요)
  const cardId = Date.now(); // 간단한 고유 ID 생성 (실제 환경에서는 더 안전한 방식 사용)
  const cardData = {
    cardId,
    userId: req.user.id, // JWT에 포함된 사용자 ID를 사용 (예: { id: '사용자ID' })
    cardNumber,
    expiry,
    cvv,
    cardHolder,
    registeredAt: new Date()
  };

  // 카드 정보를 저장 (실제 서비스에서는 DB에 저장)
  registeredCards.push(cardData);

  return res.status(201).json({
    message: '카드 등록이 완료되었습니다.',
    cardId
  });
});

app.use(bodyParser.json());
// 카드 등록 정보를 휴면 상태로 전환하는 엔드포인트 (POST /pay/del)
// 요청 본문에서 cardId를 전달받아 해당 카드의 상태를 'dormant'로 전환합니다.
app.post('/del', authenticate, (req, res) => {
    const { cardId } = req.body;
    
    if (!cardId) {
      return res.status(400).json({ error: 'cardId를 제공하세요.' });
    }
    
    // 카드 ID를 숫자로 변환 (필요한 경우)
    const cardIdInt = parseInt(cardId, 10);
    
    // 해당 카드가 존재하며 요청한 사용자 소유인지 확인
    const card = registeredCards.find(c => c.cardId === cardIdInt && c.userId === req.user.id);
    if (!card) {
      return res.status(404).json({ error: '해당 카드가 존재하지 않거나 권한이 없습니다.' });
    }
    
    // 카드 상태를 'dormant'로 전환
    card.status = 'dormant';
    
    return res.json({ message: '카드 등록 정보가 휴면 상태로 전환되었습니다.' });
  });

//타사 페이 등록 이것도 spring인듯 

//페이조회 MongoDB로 되어 있는데 firestore로 변경
