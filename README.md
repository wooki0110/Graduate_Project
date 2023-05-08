# Graduate_Project

## 졸업작품 - NoC Simulation RTL 설계
- NoCGEN(Hiroki Matsutani) 기반 RTL 설계
- SIMBA(Scalable Multi-Chip-Module-Based Deep Neural Network Inference Accelerator) architecture design
- Dataflow simulation

(1) 4*5 router 확장
- noctest.v & noc.v signal 확장

![image](https://user-images.githubusercontent.com/98706037/236812554-a4b65faf-e07b-4a71-a4de-648aef8d6fe5.png)

(2) Packet Generator
- SIMBA의 flit 구성에 맞춘 flit 설계

![image](https://user-images.githubusercontent.com/98706037/236812692-371b99c7-9445-4b8e-a535-1a1950df64c0.png)

- packet generator 모든 router에 대해 통합

(3) BRCP(Base_routing_conformed_path) 모델 설계
- BRCP multidestination 설계
- Foward&absorb 
