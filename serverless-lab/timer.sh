#!/bin/bash
curl -X POST "${FUNCTION}" -H "Content-Type:application/json" --data '{"num1": 5, "num2": 7}'