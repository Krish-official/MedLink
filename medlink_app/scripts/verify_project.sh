#!/bin/bash

echo "🔍 MedCare Project Verification"
echo "================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_count=0
pass_count=0

function check() {
    check_count=$((check_count + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# 1. Check Flutter installation
echo "\n📱 Checking Flutter..."
flutter --version > /dev/null 2>&1
check $? "Flutter is installed"

# 2. Check dependencies
echo "\n📚 Checking dependencies..."
flutter pub get > /dev/null 2>&1
check $? "Dependencies installed"

# 3. Check code generation
echo "\n⚙️  Checking generated code..."
ls lib/**/*.g.dart > /dev/null 2>&1
check $? "Code generation files exist"

# 4. Check analysis
echo "\n🔍 Running static analysis..."
flutter analyze > /dev/null 2>&1
check $? "No analysis issues"

# 5. Check formatting
echo "\n📝 Checking code formatting..."
dart format --set-exit-if-changed lib/ test/ > /dev/null 2>&1
check $? "Code is properly formatted"

# 6. Check for required files
echo "\n📄 Checking required files..."
[ -f "pubspec.yaml" ]
check $? "pubspec.yaml exists"

[ -f "lib/main.dart" ]
check $? "main.dart exists"

[ -f ".env.example" ]
check $? ".env.example exists"

[ -f "README.md" ]
check $? "README.md exists"

# 7. Check folder structure
echo "\n📁 Checking folder structure..."
[ -d "lib/core" ]
check $? "lib/core exists"

[ -d "lib/features" ]
check $? "lib/features exists"

[ -d "test" ]
check $? "test directory exists"

# 8. Run tests
echo "\n🧪 Running tests..."
flutter test > /dev/null 2>&1
check $? "All tests pass"

# 9. Check assets
echo "\n🖼️  Checking assets..."
[ -d "assets" ]
check $? "assets directory exists"

[ -d "assets/fonts" ]
check $? "fonts directory exists"

# Summary
echo "\n================================"
echo "📊 Verification Summary"
echo "================================"
echo "Passed: $pass_count/$check_count checks"

if [ $pass_count -eq $check_count ]; then
    echo -e "${GREEN}✅ All checks passed! Project is ready.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some checks failed. Please review.${NC}"
    exit 1
fi