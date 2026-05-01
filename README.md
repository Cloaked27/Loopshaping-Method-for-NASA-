# Monitoring Satellite Control: Loop Shaping Synthesis

This repository contains the solution for a control systems design project (TSA). The objective is to design a robust control law for a monitoring satellite using frequency-domain loop shaping techniques.

## Project Objectives

* Present and analyze the nominal model of a monitoring satellite.
* Translate physical performance requirements (e.g., monitoring geophysical phenomena) into frequency weights.
* Analyze model uncertainties and the limitations they impose on the design phase.
* Ensure robust stability and performance indicators to guarantee safe satellite operation during monitoring maneuvers.
* Rigorously validate the obtained results and discuss the trade-offs between design objectives.

---

## 1. Model Analysis

The plant $P(s)$ represents a simplified model of the satellites used by NASA in the GRACE-FO mission. The transfer function from the voltage applied to the reaction wheels to the satellite's pitch angle is defined as:

$$P(s) = \frac{10}{s(100s+1)(0.1s+1)}$$

**System Dynamics:**
* The term $\frac{1}{s(100s+1)}$ models the satellite's rotational dynamics. The pole at -0.01 accounts for rarefied atmospheric friction, as the GRACE-FO mission operates at a low Earth orbit of approximately 500 km.
* The term $\frac{1}{0.1s+1}$ models the dynamics of the reaction wheels used to adjust the satellite's orientation. The 100 ms time constant is standard for aerospace reaction wheels.
* The system gain of 10 is determined by the satellite's geometric configuration.
* Onboard sensor dynamics are negligible and have been omitted.

---

## 2. Performance Specifications

The mission requires the satellite to monitor melting ice caps and glaciers with microradian precision. Additionally, the controller must compensate for deviations caused by the high orbital speed.

**Control Requirements:**
* Zero steady-state error for a unit step reference.
* Steady-state error strictly below 0.1% for harmonic references within the bandwidth of $(0, 0.1)$ rad/s.

Satisfying these constraints naturally ensures the rejection of solar pressure disturbances, which are relatively low at this operational altitude. To achieve this, a performance weight $W_S(s)$ is designed such that $||W_S S||_\infty < 1$, where $S(s)$ is the sensitivity function.

---

## 3. Uncertainty Modeling

Unlike many orbital applications, the GRACE-FO satellites lack significant structural flexibility (e.g., large lateral solar panels). Consequently, the primary source of modeling uncertainty comes from the 4 pyramidal reaction wheels.

Due to minor manufacturing and positioning imperfections, the high-frequency response of the actuators cannot be determined with perfect precision. Factoring in the 100 ms time constant, the unstructured multiplicative uncertainty of the system is characterized by the following transfer function:

$$W_T(s) = \frac{0.01s}{0.001s+1}$$

A fundamental condition for successful loop shaping is ensuring that $\min(|W_S(j\omega)|, |W_T(j\omega)|) < 1$ for all frequencies.

---

## 4. Loop Shaping Constraints

The core of the project involves shaping the open-loop transfer function $L(s)$ to simultaneously satisfy strict boundaries:

* **Low-Frequency Performance:** $|L(j\omega)| > \frac{|W_S(j\omega)|}{1 - |W_T(j\omega)|}$
* **High-Frequency Robustness:** $|L(j\omega)| < \frac{1 - |W_S(j\omega)|}{|W_T(j\omega)|}$
* **Crossover & Roll-off:** The slope of $|L(j\omega)|$ near the crossover frequency must not be steeper than -40 dB/dec.
* **Controller Characteristics:** The resulting controller $C(s)$ must be stable, proper, and restrict its zeros to the left half-plane to mitigate high-frequency measurement noise and reference shocks.

---

## 5. Controller Tuning & Robustness

Due to the exorbitant costs associated with repairing orbital systems, aerospace controllers require exceptional fault resilience. To guarantee this level of robust stability:
* The initial controller was augmented with phase lead compensators to ensure a phase margin of at least 30°.
* Further iterations aimed to secure a vector margin close to the industry standard of 0.5.

---

## 6. Validation

The final controller was rigorously validated against two major criteria:
1. **Nominal Stability:** Verified by ensuring all roots of $1 + L_3(s)$ remain in the left half-plane.
2. **Robust Performance:** Confirmed by evaluating $\gamma_{prob}$ to ensure it strictly remains below 1:

$$\gamma_{prob} = \sup_{\omega \in \mathbb{R}} \left( |W_S(j\omega)S(j\omega)| + |W_T(j\omega)T(j\omega)| \right) < 1$$

---

## Deliverables

* `Name_Group.m`: MATLAB script containing the system definitions, iterative loop shaping calculations, and validation plots.
* `Name_Group.pdf`: A concise document detailing the mathematical rationale behind the chosen controller blocks, poles, and zeros.
