const express = require("express");
const router = express.Router();
const { admin, db } = require("../config/firebaseAdmin"); // Firebase 설정 가져오기

import firebase from "firebase/app";
import "firebase/auth";

const login = async (email, password) => {
    try {
      const userCredential = await firebase.auth().signInWithEmailAndPassword(email, password);
      console.log("Logged in:", userCredential.user);
    } catch (error) {
      console.error("Login failed:", error.message);
    }
  };

  
router.post("/signup", async (req, res) => {
  const { email, displayName } = req.body;

  try {
    // Firebase Authentication에서 사용자 생성
    const userRecord = await admin.auth().createUser({ email, displayName });

    // Firestore에 추가 정보 저장
    await db.collection("accounts").doc(userRecord.uid).set({
      email,
      displayName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(201).json({ message: "User created", uid: userRecord.uid });
  } catch (error) {
    res.status(400).json({ message: "Error creating user", error });
  }
});

router.get("/me", authMiddleware, async (req, res) => {
    try {
      const userDoc = await db.collection("accounts").doc(req.user.uid).get();
  
      if (!userDoc.exists) {
        return res.status(404).json({ message: "User not found" });
      }
  
      res.json({ user: userDoc.data() });
    } catch (error) {
      res.status(500).json({ message: "Error fetching user data", error });
    }
  });
  

module.exports = router;
