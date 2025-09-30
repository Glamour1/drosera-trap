# Honeypot Behavior Trap

A simple **Drosera trap** that detects suspicious honeypot-like trading behavior on tokens.  
It observes buy and sell activity over a sliding window and raises a response if:
- Buys are consistently strong,
- Sells are abnormally low or zero,
- Or the buy/sell ratio crosses a defined threshold.

This trap is intended for educational and experimental purposes only.

---

## 📂 Project Structure
