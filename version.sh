#!/bin/bash
# Seclib AI Desktop - Version Management
# Manages versioning across all components

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Get current version
get_current_version() {
    if [ -f "frontend/package.json" ]; then
        grep '"version"' frontend/package.json | head -1 | sed 's/.*"version": "\(.*\)".*/\1/'
    else
        echo "0.0.0"
    fi
}

# Update version in package.json
update_package_version() {
    local version=$1
    if [ -f "frontend/package.json" ]; then
        # Update version in package.json
        sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$version\"/" frontend/package.json
        print_status "Updated frontend/package.json to $version"
    fi
}

# Update version in other files
update_other_versions() {
    local version=$1

    # Update README if it contains version
    if [ -f "README.md" ]; then
        sed -i "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version $version/" README.md 2>/dev/null || true
    fi

    # Update any other version references as needed
    print_status "Updated version references to $version"
}

# Create git tag
create_git_tag() {
    local version=$1
    local message="${2:-Release version $version}"

    if git tag -l | grep -q "^v$version$"; then
        print_warning "Tag v$version already exists"
        return
    fi

    git tag -a "v$version" -m "$message"
    print_status "Created git tag v$version"
}

# Main version bump logic
bump_version() {
    local bump_type=$1
    local current_version=$(get_current_version)

    print_info "Current version: $current_version"

    # Parse version components
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}

    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid bump type. Use: major, minor, or patch"
            ;;
    esac

    local new_version="$major.$minor.$patch"
    print_info "New version: $new_version"

    # Confirm
    read -p "Bump version from $current_version to $new_version? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Version bump cancelled"
        exit 0
    fi

    # Update files
    update_package_version "$new_version"
    update_other_versions "$new_version"

    # Commit changes
    git add .
    git commit -m "Bump version to $new_version"

    # Create tag
    create_git_tag "$new_version"

    print_status "Version bumped to $new_version"
    print_info "Run 'git push && git push --tags' to publish"
}

# Set specific version
set_version() {
    local new_version=$1

    # Validate version format
    if ! [[ $new_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format. Use: major.minor.patch"
    fi

    print_info "Setting version to $new_version"

    # Confirm
    read -p "Set version to $new_version? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Version set cancelled"
        exit 0
    fi

    # Update files
    update_package_version "$new_version"
    update_other_versions "$new_version"

    # Commit changes
    git add .
    git commit -m "Set version to $new_version"

    # Create tag
    create_git_tag "$new_version"

    print_status "Version set to $new_version"
    print_info "Run 'git push && git push --tags' to publish"
}

# Show usage
usage() {
    echo "Seclib AI Desktop - Version Management"
    echo ""
    echo "Usage:"
    echo "  $0 bump <type>     Bump version (major, minor, patch)"
    echo "  $0 set <version>   Set specific version (x.y.z)"
    echo "  $0 current         Show current version"
    echo ""
    echo "Examples:"
    echo "  $0 bump patch      # 1.0.0 -> 1.0.1"
    echo "  $0 bump minor      # 1.0.0 -> 1.1.0"
    echo "  $0 set 2.0.0       # Set to 2.0.0"
}

# Main script logic
case "${1:-}" in
    bump)
        if [ -z "$2" ]; then
            print_error "Bump type required (major, minor, patch)"
        fi
        bump_version "$2"
        ;;
    set)
        if [ -z "$2" ]; then
            print_error "Version required"
        fi
        set_version "$2"
        ;;
    current)
        echo "Current version: $(get_current_version)"
        ;;
    *)
        usage
        exit 1
        ;;
esac