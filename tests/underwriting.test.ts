import { describe, it, expect, beforeEach } from "vitest"

const mockContract = {
  admin: "STADMIN1111111111111111111111111111111",
  riskScores: new Map(),
  basePremiumTiers: new Map(),
  premiumDiscounts: new Map(),
  policySubmissions: new Map(),

  isAdmin(caller: string) {
    return caller === this.admin
  },

  setBasePremiumTier(caller: string, tier: number, bps: number) {
    if (!this.isAdmin(caller)) return { error: 100 }
    this.basePremiumTiers.set(tier, bps)
    return { value: true }
  },

  setPremiumDiscount(caller: string, farmer: string, bps: number) {
    if (!this.isAdmin(caller)) return { error: 100 }
    this.premiumDiscounts.set(farmer, bps)
    return { value: true }
  },

  submitRiskScore(caller: string, farmer: string, cropType: string, season: string, score: number) {
    if (!this.isAdmin(caller)) return { error: 100 }
    const key = `${farmer}-${cropType}-${season}`
    if (this.riskScores.has(key)) return { error: 102 }
    if (score > 100) return { error: 103 }
    this.riskScores.set(key, score)
    return { value: true }
  },

  getBasePremium(score: number) {
    if (score > 100) return { error: 103 }
    let tier = 1
    if (score <= 20) tier = 1
    else if (score <= 40) tier = 2
    else if (score <= 60) tier = 3
    else if (score <= 80) tier = 4
    else tier = 5

    if (!this.basePremiumTiers.has(tier)) return { error: 104 }
    return { value: this.basePremiumTiers.get(tier)! }
  },

  calculateFinalPremium(farmer: string, cropType: string, season: string) {
    const key = `${farmer}-${cropType}-${season}`
    if (!this.riskScores.has(key)) return { error: 101 }
    const score = this.riskScores.get(key)!
    const base = this.getBasePremium(score)
    if ("error" in base) return base
    const discount = this.premiumDiscounts.get(farmer) || 0
    return { value: base.value > discount ? base.value - discount : 0 }
  },

  markPolicySubmitted(caller: string, farmer: string, season: string) {
    if (!this.isAdmin(caller)) return { error: 100 }
    this.policySubmissions.set(`${farmer}-${season}`, true)
    return { value: true }
  },

  hasSubmittedPolicy(farmer: string, season: string) {
    return this.policySubmissions.get(`${farmer}-${season}`) || false
  },

  transferAdmin(caller: string, newAdmin: string) {
    if (!this.isAdmin(caller)) return { error: 100 }
    this.admin = newAdmin
    return { value: true }
  }
}

describe("Underwriting Contract", () => {
  const admin = mockContract.admin
  const farmer = "STFARMER000000000000000000000000000000"
  const cropType = "maize"
  const season = "2025-Q1"

  beforeEach(() => {
    mockContract.riskScores.clear()
    mockContract.basePremiumTiers.clear()
    mockContract.premiumDiscounts.clear()
    mockContract.policySubmissions.clear()
    mockContract.admin = admin
  })

  it("calculates premium correctly with discount", () => {
    mockContract.setBasePremiumTier(admin, 2, 500) // 5%
    mockContract.setPremiumDiscount(admin, farmer, 200) // 2%
    mockContract.submitRiskScore(admin, farmer, cropType, season, 35) // tier 2
    const result = mockContract.calculateFinalPremium(farmer, cropType, season)
    expect(result).toEqual({ value: 300 })
  })

  it("returns error if risk score not found", () => {
    const result = mockContract.calculateFinalPremium(farmer, cropType, season)
    expect(result).toEqual({ error: 101 })
  })

  it("prevents non-admin from submitting risk score", () => {
    const result = mockContract.submitRiskScore("STNOTADMIN", farmer, cropType, season, 20)
    expect(result).toEqual({ error: 100 })
  })

  it("returns zero if discount exceeds premium", () => {
    mockContract.setBasePremiumTier(admin, 1, 100)
    mockContract.setPremiumDiscount(admin, farmer, 150)
    mockContract.submitRiskScore(admin, farmer, cropType, season, 10)
    const result = mockContract.calculateFinalPremium(farmer, cropType, season)
    expect(result).toEqual({ value: 0 })
  })

  it("marks policy as submitted and verifies it", () => {
    const mark = mockContract.markPolicySubmitted(admin, farmer, season)
    expect(mark).toEqual({ value: true })
    expect(mockContract.hasSubmittedPolicy(farmer, season)).toBe(true)
  })

  it("transfers admin rights", () => {
    const newAdmin = "STNEWADMIN222222222222222222222222222"
    const transfer = mockContract.transferAdmin(admin, newAdmin)
    expect(transfer).toEqual({ value: true })
    expect(mockContract.admin).toBe(newAdmin)
  })
})
