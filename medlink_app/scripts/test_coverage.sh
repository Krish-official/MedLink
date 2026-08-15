#!/bin/bash

echo "📊 Generating Test Coverage Report..."

# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "✅ Coverage report generated at: coverage/html/index.html"
    
    # Open in browser (macOS/Linux)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open coverage/html/index.html
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open coverage/html/index.html
    fi
else
    echo "⚠️  lcov not installed. Install with: brew install lcov (macOS) or apt-get install lcov (Linux)"
fi

# Show coverage summary
echo "\n📈 Coverage Summary:"
lcov --summary coverage/lcov.info