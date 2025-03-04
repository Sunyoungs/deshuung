const express = require('express');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const app = express();
const BLACKLISTED_TOKENS = new Set(); // 블랙리스트 저장

//mongoDB로 되어 있음 -> firestore로 변경 
// 회원가입 엔드포인트 (변경: '/register' → '/user/register')
app.post('/register', async (req, res) => {
    try {
        const { username, email, password } = req.body;

        // 기존 사용자 확인
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: '이미 존재하는 이메일입니다.' });
        }

        // 비밀번호 해싱
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 새로운 사용자 생성
        const newUser = new User({ username, email, password: hashedPassword });
        await newUser.save();

        res.status(201).json({ message: '회원가입 성공' });
    } catch (error) {
        res.status(500).json({ message: '서버 오류', error });
    }
});


// 로그아웃 엔드포인트 (블랙리스트 방식)
app.post('/logout', (req, res) => {
    const token = req.headers.authorization?.split(' ')[1]; // Bearer 토큰 추출
    if (!token) return res.status(401).json({ message: "토큰 없음" });

    BLACKLISTED_TOKENS.add(token); // 토큰 블랙리스트 추가
    res.json({ message: "로그아웃 성공" });
});

// 인증 미들웨어 (블랙리스트 체크)
const authenticate = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ message: "인증 실패" });

    if (BLACKLISTED_TOKENS.has(token)) return res.status(401).json({ message: "토큰이 만료되었습니다." });

    jwt.verify(token, 'your_secret_key', (err, decoded) => {
        if (err) return res.status(401).json({ message: "유효하지 않은 토큰" });
        req.user = decoded;
        next();
    });
};

// 가짜 사용자 데이터베이스 (예제용)
const users = [
    { id: 1, username: 'user1', password: bcrypt.hashSync('password123', 10) },
    { id: 2, username: 'user2', password: bcrypt.hashSync('mypassword', 10) }
];

// JWT 시크릿 키
const SECRET_KEY = 'your_secret_key';

app.use(bodyParser.json());

// 로그인 엔드포인트 (변경: '/user/login')
app.post('/user/login', (req, res) => {
    const { username, password } = req.body;
    const user = users.find(u => u.username === username);
    
    if (!user) {
        return res.status(401).json({ message: 'Invalid username or password' });
    }

    // 비밀번호 비교
    if (!bcrypt.compareSync(password, user.password)) {
        return res.status(401).json({ message: 'Invalid username or password' });
    }

    // JWT 생성
    const token = jwt.sign({ id: user.id, username: user.username }, SECRET_KEY, { expiresIn: '1h' });
    res.json({ token });
});

// 인증된 사용자만 접근 가능한 라우트 예제
app.get('/protected', (req, res) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
        return res.status(401).json({ message: 'Access denied' });
    }

    try {
        const decoded = jwt.verify(token, SECRET_KEY);
        res.json({ message: 'Welcome to the protected route!', user: decoded });
    } catch (err) {
        res.status(401).json({ message: 'Invalid token' });
    }
});
