# LaTeX Render Test

A test file for `Render-Readme.ps1`. Run it with:

```powershell
pwsh .\Render-Readme.ps1 latex-test.md
pwsh .\Render-Readme.ps1 latex-test.md -Browser
```

If everything works, every formula below turns into readable math and no raw `$` or `\command` text is left (except inside code blocks, where it must stay untouched).

## 1. Inline math

Euler's identity is $e^{i\pi} + 1 = 0$, and the golden ratio is $\phi = \frac{1+\sqrt{5}}{2}$.

The area of a circle is $A = \pi r^2$, the energy is $E = mc^2$, and $x_1, x_2, \ldots, x_n$ are the roots.

Using the other inline style: \(a^2 + b^2 = c^2\).

## 2. Display math

$$\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$$

$$\int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}$$

\[
\nabla \cdot \vec{E} = \frac{\rho}{\varepsilon_0}
\]

Multi-line display block:

$$
f(x) = \alpha x^2 + \beta x + \gamma
$$

## 3. Greek letters

Lowercase: $\alpha, \beta, \gamma, \delta, \epsilon, \theta, \lambda, \mu, \pi, \sigma, \phi, \omega$

Uppercase: $\Gamma, \Delta, \Theta, \Lambda, \Pi, \Sigma, \Phi, \Psi, \Omega$

Case check: $\gamma \ne \Gamma$ and $\delta \ne \Delta$.

## 4. Number theory (modular arithmetic)

Fermat's little theorem: $a^{p-1} \equiv 1 \pmod{p}$ for prime $p$.

Congruences: $x \equiv 1 \pmod 4$ and $x \equiv 3 \pmod 6$ have no common solution.

Remainder: $ab \bmod m$, and $\gcd(a, b) = 1$.

Chinese Remainder Theorem: $x \equiv a_1 \pmod{m_1}$, $x \equiv a_2 \pmod{m_2}$.

Euler's totient: $\varphi(n) = n \prod_{p \mid n} \left(1 - \frac{1}{p}\right)$

Floor and ceiling: $\lfloor 3.7 \rfloor = 3$ and $\lceil 3.2 \rceil = 4$.

Binomial: $\binom{n}{k} = \frac{n!}{k!(n-k)!}$

## 4b. Calculus: integrals, derivatives, limits

Definite integral: $\int_0^1 x^2\,dx = \frac{1}{3}$

Indefinite: $\int \sin x \, dx = -\cos x + C$

Limits of integration with letters: $\int_a^b f(x)\,dx = F(b) - F(a)$

Double and triple integrals: $\iint_D f(x,y)\,dA$ and $\iiint_V \rho \, dV$

Closed contour: $\oint_C \vec{F} \cdot d\vec{r}$

Derivative: $\frac{d}{dx} x^n = n x^{n-1}$ and $f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$

Second derivative: $\frac{d^2 y}{dx^2}$ and $\ddot{x} + \omega^2 x = 0$

Partial derivatives: $\frac{\partial f}{\partial x}$, $\frac{\partial^2 f}{\partial x \partial y}$, $\partial_t u = \alpha \nabla^2 u$

Gradient, divergence, curl: $\nabla f$, $\nabla \cdot \vec{F}$, $\nabla \times \vec{F}$

Limits: $\lim_{x \to \infty} \frac{1}{x} = 0$ and $\lim_{n \to \infty} \left(1 + \frac{1}{n}\right)^n = e$

Series: $\sum_{k=0}^{\infty} \frac{x^k}{k!} = e^x$ and $\prod_{k=1}^{n} k = n!$

Sets of numbers: $\mathbb{N} \subset \mathbb{Z} \subset \mathbb{Q} \subset \mathbb{R} \subset \mathbb{C}$

Display versions:

$$\frac{\partial^2 u}{\partial t^2} = c^2 \nabla^2 u$$

$$\iint_S \vec{F} \cdot \hat{n} \, dS = \iiint_V \nabla \cdot \vec{F} \, dV$$

$$\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}$$

## 5. Operators and relations

$a \leq b$, $a \geq b$, $a \neq b$, $a \approx b$, $a \equiv b$, $a \pm b$, $a \times b$, $a \cdot b$

Sets: $x \in A$, $x \notin B$, $A \subset B$, $A \subseteq B$, $A \cup B$, $A \cap B$, $\emptyset$

Logic: $\forall x \exists y$, $p \land q$, $p \lor q$, $\neg p$, $p \implies q$, $p \iff q$

Arrows: $a \to b$, $a \rightarrow b$, $a \Rightarrow b$, $a \Leftrightarrow b$, $x \mapsto x^2$

## 6. Superscripts and subscripts

$x^2$, $x^{10}$, $x^{n+1}$, $a_i$, $a_{ij}$, $a_{n-1}$, $x_1^2$, $2^{n}$, $10^{-3}$

Not available as Unicode (falls back to plain text): $a^{xy}$, $b_{q}^{z}$

## 7. Fractions and roots

$\frac{1}{2}$, $\frac{a+b}{c+d}$, $\frac{x^2}{y^2}$, $\sqrt{2}$, $\sqrt{x+1}$, $\sqrt n$

Nested: $\frac{1}{1 + \frac{1}{x}}$

## 8. Things that must NOT be converted

Prices: it costs $5 and then $10 more, so $15 in total.

Inline code stays raw: `$x^2$` and `\frac{a}{b}` and `$$not math$$`.

```python
# Code blocks keep dollar signs and backslashes exactly as written
price = "$5"
formula = r"\frac{a}{b}"
total = f"${price}"
```

```cpp
// Chinese remainder in C++
long long crt(long long a1, long long m1, long long a2, long long m2) {
    for (long long x = a1; x < m1 * m2; x += m1)
        if (x % m2 == a2) return x;
    return -1;
}
```

## 9. Normal Markdown (colors and formatting check)

**Bold text**, *italic text*, ~~strikethrough~~, and a [link](https://example.com).

- Bullet one with math $x^2$
- Bullet two with $\alpha + \beta$
  - Nested bullet with $\sqrt{2}$

1. First step: compute $n \bmod m$
2. Second step: check $\gcd(n, m) = 1$

> A block quote with math: $a^2 + b^2 = c^2$

| Symbol | Meaning |
|--------|---------|
| $\pi$ | circle constant |
| $e$ | Euler's number |
| $\infty$ | infinity |

---

## 10. Known limits (terminal mode only)

These are approximated in the terminal and look best with `-Browser`:

$$
\begin{pmatrix} a & b \\ c & d \end{pmatrix}
$$

$$
\begin{aligned}
x &= 1 \\
y &= 2
\end{aligned}
$$

End of test.
