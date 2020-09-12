# Welcome to the Oahu Error documentation file!

This document was written by Avenze, I'm going to document most possible reasons to why internal issues appear in Oahu, this document is mostly only for use by developers for debugging certain issues within Oahu.

- VF : Vehicle Functions
- HM : Housing Module

# VF Documentation

- VF-PF1 : The purchase function of the VehicleFunctions module failed, and it returned an unknown stacktrace.
- VF-SV1 : The spawn function of the VehicleFunctions module failed, and it also returned an unknown stacktrace, this means that no returns of the module were ever fired, which could mean that it's an unhandled error.

# HM Documentation

- HM-PF1 : No returns were ever fired, so it fell back to returning this error, this means an unknown error.
- HM-PF2 : The purchase function could have returned incorrect data, this should never fire incase of the player ever purchasing something while purchasing a vehicle deducting their money.
