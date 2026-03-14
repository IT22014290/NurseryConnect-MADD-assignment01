#!/usr/bin/env python3
"""
Generates a complete Xcode project (.xcodeproj) for NurseryConnect iOS app.
"""

import os
import uuid

def new_id():
    return uuid.uuid4().hex[:24].upper()

# All source files
APP_FILES = [
    "NurseryConnect/NurseryConnectApp.swift",
    "NurseryConnect/ContentView.swift",
    "NurseryConnect/Models/Child.swift",
    "NurseryConnect/Models/DiaryEntry.swift",
    "NurseryConnect/Models/IncidentReport.swift",
    "NurseryConnect/Utilities/NurseryTheme.swift",
    "NurseryConnect/Utilities/SampleData.swift",
    "NurseryConnect/Views/Components/NurseryCard.swift",
    "NurseryConnect/Views/Dashboard/DashboardView.swift",
    "NurseryConnect/Views/Dashboard/ChildCardView.swift",
    "NurseryConnect/Views/Profile/ChildDetailView.swift",
    "NurseryConnect/Views/Profile/ChildProfileView.swift",
    "NurseryConnect/Views/Diary/DailyDiaryView.swift",
    "NurseryConnect/Views/Diary/AddDiaryEntryView.swift",
    "NurseryConnect/Views/Incidents/IncidentListView.swift",
    "NurseryConnect/Views/Incidents/IncidentFormView.swift",
    "NurseryConnect/Views/Incidents/IncidentDetailView.swift",
]

TEST_FILES = [
    "NurseryConnectTests/NurseryConnectTests.swift",
]

# Generate UUIDs for all components
PROJECT_ID = new_id()
APP_TARGET_ID = new_id()
TEST_TARGET_ID = new_id()
MAIN_GROUP_ID = new_id()
APP_GROUP_ID = new_id()
TEST_GROUP_ID = new_id()
PRODUCTS_GROUP_ID = new_id()
FRAMEWORKS_GROUP_ID = new_id()

CONFIGS = {
    'project_debug': new_id(),
    'project_release': new_id(),
    'app_debug': new_id(),
    'app_release': new_id(),
    'test_debug': new_id(),
    'test_release': new_id(),
}

CONFIG_LIST_PROJECT = new_id()
CONFIG_LIST_APP = new_id()
CONFIG_LIST_TEST = new_id()

BUILD_PHASE_SOURCES_APP = new_id()
BUILD_PHASE_SOURCES_TEST = new_id()
BUILD_PHASE_FRAMEWORKS_APP = new_id()
BUILD_PHASE_FRAMEWORKS_TEST = new_id()
BUILD_PHASE_RESOURCES_APP = new_id()

APP_PRODUCT_ID = new_id()
TEST_PRODUCT_ID = new_id()
CONTAINER_PROXY_ID = new_id()
DEPENDENCY_ID = new_id()

# Assign IDs to each file
app_file_ids = {}   # path -> (file_ref_id, build_file_id)
for f in APP_FILES:
    app_file_ids[f] = (new_id(), new_id())

test_file_ids = {}
for f in TEST_FILES:
    test_file_ids[f] = (new_id(), new_id())

# Group structure
# We'll create sub-groups for each folder
group_ids = {}
folders = set()
for f in APP_FILES:
    parts = f.split('/')
    for i in range(1, len(parts)):
        folder = '/'.join(parts[:i])
        folders.add(folder)
        if folder not in group_ids:
            group_ids[folder] = new_id()

# Override top-level groups
group_ids['NurseryConnect'] = APP_GROUP_ID
group_ids['NurseryConnectTests'] = TEST_GROUP_ID

def get_parent(path):
    parts = path.split('/')
    if len(parts) <= 1:
        return None
    return '/'.join(parts[:-1])

def get_name(path):
    return path.split('/')[-1]

def file_type(fname):
    if fname.endswith('.swift'):
        return 'sourcecode.swift'
    elif fname.endswith('.plist'):
        return 'text.plist.xml'
    elif fname.endswith('.xib'):
        return 'file.xib'
    return 'text'

def build_pbxproj():
    lines = []
    lines.append('// !$*UTF8*$!')
    lines.append('{')
    lines.append('\tarchiveVersion = 1;')
    lines.append('\tclasses = {')
    lines.append('\t};')
    lines.append('\tobjectVersion = 56;')
    lines.append('\tobjects = {')
    lines.append('')

    # === PBXBuildFile ===
    lines.append('/* Begin PBXBuildFile section */')
    for path, (fref, bfile) in app_file_ids.items():
        name = get_name(path)
        lines.append(f'\t\t{bfile} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fref} /* {name} */; }};')
    for path, (fref, bfile) in test_file_ids.items():
        name = get_name(path)
        lines.append(f'\t\t{bfile} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fref} /* {name} */; }};')
    lines.append('/* End PBXBuildFile section */')
    lines.append('')

    # === PBXContainerItemProxy ===
    lines.append('/* Begin PBXContainerItemProxy section */')
    lines.append(f'\t\t{CONTAINER_PROXY_ID} /* PBXContainerItemProxy */ = {{')
    lines.append(f'\t\t\tisa = PBXContainerItemProxy;')
    lines.append(f'\t\t\tcontainerPortal = {PROJECT_ID} /* Project object */;')
    lines.append(f'\t\t\tproxyType = 1;')
    lines.append(f'\t\t\tremoteGlobalIDString = {APP_TARGET_ID};')
    lines.append(f'\t\t\tremoteInfo = NurseryConnect;')
    lines.append(f'\t\t}};')
    lines.append('/* End PBXContainerItemProxy section */')
    lines.append('')

    # === PBXFileReference ===
    lines.append('/* Begin PBXFileReference section */')
    lines.append(f'\t\t{APP_PRODUCT_ID} /* NurseryConnect.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = NurseryConnect.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
    lines.append(f'\t\t{TEST_PRODUCT_ID} /* NurseryConnectTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = NurseryConnectTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};')
    for path, (fref, bfile) in {**app_file_ids, **test_file_ids}.items():
        name = get_name(path)
        ftype = file_type(name)
        lines.append(f'\t\t{fref} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {ftype}; path = {name}; sourceTree = "<group>"; }};')
    lines.append('/* End PBXFileReference section */')
    lines.append('')

    # === PBXFrameworksBuildPhase ===
    lines.append('/* Begin PBXFrameworksBuildPhase section */')
    lines.append(f'\t\t{BUILD_PHASE_FRAMEWORKS_APP} /* Frameworks */ = {{')
    lines.append(f'\t\t\tisa = PBXFrameworksBuildPhase;')
    lines.append(f'\t\t\tbuildActionMask = 2147483647;')
    lines.append(f'\t\t\tfiles = (')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append(f'\t\t}};')
    lines.append(f'\t\t{BUILD_PHASE_FRAMEWORKS_TEST} /* Frameworks */ = {{')
    lines.append(f'\t\t\tisa = PBXFrameworksBuildPhase;')
    lines.append(f'\t\t\tbuildActionMask = 2147483647;')
    lines.append(f'\t\t\tfiles = (')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append(f'\t\t}};')
    lines.append('/* End PBXFrameworksBuildPhase section */')
    lines.append('')

    # === PBXGroup ===
    lines.append('/* Begin PBXGroup section */')

    # Main group
    lines.append(f'\t\t{MAIN_GROUP_ID} /* MainGroup */ = {{')
    lines.append(f'\t\t\tisa = PBXGroup;')
    lines.append(f'\t\t\tchildren = (')
    lines.append(f'\t\t\t\t{APP_GROUP_ID} /* NurseryConnect */,')
    lines.append(f'\t\t\t\t{TEST_GROUP_ID} /* NurseryConnectTests */,')
    lines.append(f'\t\t\t\t{PRODUCTS_GROUP_ID} /* Products */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tsourceTree = "<group>";')
    lines.append(f'\t\t}};')

    # Products group
    lines.append(f'\t\t{PRODUCTS_GROUP_ID} /* Products */ = {{')
    lines.append(f'\t\t\tisa = PBXGroup;')
    lines.append(f'\t\t\tchildren = (')
    lines.append(f'\t\t\t\t{APP_PRODUCT_ID} /* NurseryConnect.app */,')
    lines.append(f'\t\t\t\t{TEST_PRODUCT_ID} /* NurseryConnectTests.xctest */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tname = Products;')
    lines.append(f'\t\t\tsourceTree = "<group>";')
    lines.append(f'\t\t}};')

    # Build groups for all folders in app
    def get_children(parent_path, all_files, all_groups):
        children = []
        # Sub-groups
        for folder in sorted(all_groups.keys()):
            par = get_parent(folder)
            if par == parent_path:
                children.append((all_groups[folder], get_name(folder) + '/'))
        # Files directly in this folder
        for fpath, (fref, _) in all_files.items():
            fpar = '/'.join(fpath.split('/')[:-1])
            if fpar == parent_path:
                children.append((fref, get_name(fpath)))
        return children

    # App group children
    app_children = get_children('NurseryConnect', app_file_ids, {k: v for k,v in group_ids.items() if k.startswith('NurseryConnect/') and k.count('/') == 1})
    lines.append(f'\t\t{APP_GROUP_ID} /* NurseryConnect */ = {{')
    lines.append(f'\t\t\tisa = PBXGroup;')
    lines.append(f'\t\t\tchildren = (')
    for gid, name in app_children:
        lines.append(f'\t\t\t\t{gid} /* {name.rstrip("/")} */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tpath = NurseryConnect;')
    lines.append(f'\t\t\tsourceTree = "<group>";')
    lines.append(f'\t\t}};')

    # Sub-groups under NurseryConnect
    sub_folders = sorted([k for k in group_ids.keys() if k.startswith('NurseryConnect/') and k != 'NurseryConnect'])
    for folder in sub_folders:
        gid = group_ids[folder]
        # Get children of this folder
        direct_children = []
        for sub in sorted(group_ids.keys()):
            par = get_parent(sub)
            if par == folder:
                direct_children.append((group_ids[sub], get_name(sub)))
        for fpath, (fref, _) in app_file_ids.items():
            fpar = '/'.join(fpath.split('/')[:-1])
            if fpar == folder:
                direct_children.append((fref, get_name(fpath)))
        lines.append(f'\t\t{gid} /* {get_name(folder)} */ = {{')
        lines.append(f'\t\t\tisa = PBXGroup;')
        lines.append(f'\t\t\tchildren = (')
        for cid, cname in direct_children:
            lines.append(f'\t\t\t\t{cid} /* {cname} */,')
        lines.append(f'\t\t\t);')
        lines.append(f'\t\t\tpath = {get_name(folder)};')
        lines.append(f'\t\t\tsourceTree = "<group>";')
        lines.append(f'\t\t}};')

    # Test group
    test_file_refs = [(fref, get_name(fpath)) for fpath, (fref, _) in test_file_ids.items()]
    lines.append(f'\t\t{TEST_GROUP_ID} /* NurseryConnectTests */ = {{')
    lines.append(f'\t\t\tisa = PBXGroup;')
    lines.append(f'\t\t\tchildren = (')
    for fref, fname in test_file_refs:
        lines.append(f'\t\t\t\t{fref} /* {fname} */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tpath = NurseryConnectTests;')
    lines.append(f'\t\t\tsourceTree = "<group>";')
    lines.append(f'\t\t}};')

    lines.append('/* End PBXGroup section */')
    lines.append('')

    # === PBXNativeTarget ===
    lines.append('/* Begin PBXNativeTarget section */')
    lines.append(f'\t\t{APP_TARGET_ID} /* NurseryConnect */ = {{')
    lines.append(f'\t\t\tisa = PBXNativeTarget;')
    lines.append(f'\t\t\tbuildConfigurationList = {CONFIG_LIST_APP} /* Build configuration list for PBXNativeTarget "NurseryConnect" */;')
    lines.append(f'\t\t\tbuildPhases = (')
    lines.append(f'\t\t\t\t{BUILD_PHASE_SOURCES_APP} /* Sources */,')
    lines.append(f'\t\t\t\t{BUILD_PHASE_FRAMEWORKS_APP} /* Frameworks */,')
    lines.append(f'\t\t\t\t{BUILD_PHASE_RESOURCES_APP} /* Resources */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tbuildRules = (')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tdependencies = (')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tname = NurseryConnect;')
    lines.append(f'\t\t\tpackageProductDependencies = (')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tproductName = NurseryConnect;')
    lines.append(f'\t\t\tproductReference = {APP_PRODUCT_ID} /* NurseryConnect.app */;')
    lines.append(f'\t\t\tproductType = "com.apple.product-type.application";')
    lines.append(f'\t\t}};')

    lines.append(f'\t\t{TEST_TARGET_ID} /* NurseryConnectTests */ = {{')
    lines.append(f'\t\t\tisa = PBXNativeTarget;')
    lines.append(f'\t\t\tbuildConfigurationList = {CONFIG_LIST_TEST} /* Build configuration list for PBXNativeTarget "NurseryConnectTests" */;')
    lines.append(f'\t\t\tbuildPhases = (')
    lines.append(f'\t\t\t\t{BUILD_PHASE_SOURCES_TEST} /* Sources */,')
    lines.append(f'\t\t\t\t{BUILD_PHASE_FRAMEWORKS_TEST} /* Frameworks */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tbuildRules = (')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tdependencies = (')
    lines.append(f'\t\t\t\t{DEPENDENCY_ID} /* PBXTargetDependency */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tname = NurseryConnectTests;')
    lines.append(f'\t\t\tproductName = NurseryConnectTests;')
    lines.append(f'\t\t\tproductReference = {TEST_PRODUCT_ID} /* NurseryConnectTests.xctest */;')
    lines.append(f'\t\t\tproductType = "com.apple.product-type.bundle.unit-test";')
    lines.append(f'\t\t}};')
    lines.append('/* End PBXNativeTarget section */')
    lines.append('')

    # === PBXProject ===
    lines.append('/* Begin PBXProject section */')
    lines.append(f'\t\t{PROJECT_ID} /* Project object */ = {{')
    lines.append(f'\t\t\tisa = PBXProject;')
    lines.append(f'\t\t\tattributes = {{')
    lines.append(f'\t\t\t\tBuildIndependentTargetsInParallel = 1;')
    lines.append(f'\t\t\t\tLastSwiftUpdateCheck = 1540;')
    lines.append(f'\t\t\t\tLastUpgradeCheck = 1540;')
    lines.append(f'\t\t\t\tTargetAttributes = {{')
    lines.append(f'\t\t\t\t\t{APP_TARGET_ID} = {{')
    lines.append(f'\t\t\t\t\t\tCreatedOnToolsVersion = 15.4;')
    lines.append(f'\t\t\t\t\t}};')
    lines.append(f'\t\t\t\t\t{TEST_TARGET_ID} = {{')
    lines.append(f'\t\t\t\t\t\tCreatedOnToolsVersion = 15.4;')
    lines.append(f'\t\t\t\t\t\tTestTargetID = {APP_TARGET_ID};')
    lines.append(f'\t\t\t\t\t}};')
    lines.append(f'\t\t\t\t}};')
    lines.append(f'\t\t\t}};')
    lines.append(f'\t\t\tbuildConfigurationList = {CONFIG_LIST_PROJECT} /* Build configuration list for PBXProject "NurseryConnect" */;')
    lines.append(f'\t\t\tcompatibilityVersion = "Xcode 15.0";')
    lines.append(f'\t\t\tdevelopmentRegion = en;')
    lines.append(f'\t\t\thasScannedForEncodings = 0;')
    lines.append(f'\t\t\tknownRegions = (')
    lines.append(f'\t\t\t\ten,')
    lines.append(f'\t\t\t\tBase,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tmainGroup = {MAIN_GROUP_ID};')
    lines.append(f'\t\t\tproductRefGroup = {PRODUCTS_GROUP_ID} /* Products */;')
    lines.append(f'\t\t\tprojectDirPath = "";')
    lines.append(f'\t\t\tprojectRoot = "";')
    lines.append(f'\t\t\ttargets = (')
    lines.append(f'\t\t\t\t{APP_TARGET_ID} /* NurseryConnect */,')
    lines.append(f'\t\t\t\t{TEST_TARGET_ID} /* NurseryConnectTests */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t}};')
    lines.append('/* End PBXProject section */')
    lines.append('')

    # === PBXResourcesBuildPhase ===
    lines.append('/* Begin PBXResourcesBuildPhase section */')
    lines.append(f'\t\t{BUILD_PHASE_RESOURCES_APP} /* Resources */ = {{')
    lines.append(f'\t\t\tisa = PBXResourcesBuildPhase;')
    lines.append(f'\t\t\tbuildActionMask = 2147483647;')
    lines.append(f'\t\t\tfiles = (')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append(f'\t\t}};')
    lines.append('/* End PBXResourcesBuildPhase section */')
    lines.append('')

    # === PBXSourcesBuildPhase ===
    lines.append('/* Begin PBXSourcesBuildPhase section */')
    lines.append(f'\t\t{BUILD_PHASE_SOURCES_APP} /* Sources */ = {{')
    lines.append(f'\t\t\tisa = PBXSourcesBuildPhase;')
    lines.append(f'\t\t\tbuildActionMask = 2147483647;')
    lines.append(f'\t\t\tfiles = (')
    for path, (fref, bfile) in app_file_ids.items():
        name = get_name(path)
        lines.append(f'\t\t\t\t{bfile} /* {name} in Sources */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append(f'\t\t}};')

    lines.append(f'\t\t{BUILD_PHASE_SOURCES_TEST} /* Sources */ = {{')
    lines.append(f'\t\t\tisa = PBXSourcesBuildPhase;')
    lines.append(f'\t\t\tbuildActionMask = 2147483647;')
    lines.append(f'\t\t\tfiles = (')
    for path, (fref, bfile) in test_file_ids.items():
        name = get_name(path)
        lines.append(f'\t\t\t\t{bfile} /* {name} in Sources */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append(f'\t\t}};')
    lines.append('/* End PBXSourcesBuildPhase section */')
    lines.append('')

    # === PBXTargetDependency ===
    lines.append('/* Begin PBXTargetDependency section */')
    lines.append(f'\t\t{DEPENDENCY_ID} /* PBXTargetDependency */ = {{')
    lines.append(f'\t\t\tisa = PBXTargetDependency;')
    lines.append(f'\t\t\ttarget = {APP_TARGET_ID} /* NurseryConnect */;')
    lines.append(f'\t\t\ttargetProxy = {CONTAINER_PROXY_ID} /* PBXContainerItemProxy */;')
    lines.append(f'\t\t}};')
    lines.append('/* End PBXTargetDependency section */')
    lines.append('')

    # === XCBuildConfiguration ===
    lines.append('/* Begin XCBuildConfiguration section */')

    # Project debug
    lines.append(f'\t\t{CONFIGS["project_debug"]} /* Debug */ = {{')
    lines.append(f'\t\t\tisa = XCBuildConfiguration;')
    lines.append(f'\t\t\tbuildSettings = {{')
    lines.append(f'\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
    lines.append(f'\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
    lines.append(f'\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
    lines.append(f'\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    lines.append(f'\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    lines.append(f'\t\t\t\tCOPY_PHASE_STRIP = NO;')
    lines.append(f'\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
    lines.append(f'\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
    lines.append(f'\t\t\t\tENABLE_TESTABILITY = YES;')
    lines.append(f'\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;')
    lines.append(f'\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
    lines.append(f'\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
    lines.append(f'\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
    lines.append(f'\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (')
    lines.append(f'\t\t\t\t\t"DEBUG=1",')
    lines.append(f'\t\t\t\t\t"$(inherited)",')
    lines.append(f'\t\t\t\t);')
    lines.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
    lines.append(f'\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
    lines.append(f'\t\t\t\tMTL_FAST_MATH = YES;')
    lines.append(f'\t\t\t\tONLY_ACTIVE_ARCH = YES;')
    lines.append(f'\t\t\t\tSDKROOT = iphoneos;')
    lines.append(f'\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;')
    lines.append(f'\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
    lines.append(f'\t\t\t}};')
    lines.append(f'\t\t\tname = Debug;')
    lines.append(f'\t\t}};')

    # Project release
    lines.append(f'\t\t{CONFIGS["project_release"]} /* Release */ = {{')
    lines.append(f'\t\t\tisa = XCBuildConfiguration;')
    lines.append(f'\t\t\tbuildSettings = {{')
    lines.append(f'\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
    lines.append(f'\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
    lines.append(f'\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
    lines.append(f'\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    lines.append(f'\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    lines.append(f'\t\t\t\tCOPY_PHASE_STRIP = NO;')
    lines.append(f'\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
    lines.append(f'\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
    lines.append(f'\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
    lines.append(f'\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;')
    lines.append(f'\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
    lines.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
    lines.append(f'\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
    lines.append(f'\t\t\t\tMTL_FAST_MATH = YES;')
    lines.append(f'\t\t\t\tSDKROOT = iphoneos;')
    lines.append(f'\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
    lines.append(f'\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";')
    lines.append(f'\t\t\t\tVALIDATE_PRODUCT = YES;')
    lines.append(f'\t\t\t}};')
    lines.append(f'\t\t\tname = Release;')
    lines.append(f'\t\t}};')

    # App target debug
    lines.append(f'\t\t{CONFIGS["app_debug"]} /* Debug */ = {{')
    lines.append(f'\t\t\tisa = XCBuildConfiguration;')
    lines.append(f'\t\t\tbuildSettings = {{')
    lines.append(f'\t\t\t\tASSTECATALOG_COMPILER_APPICON_NAME = AppIcon;')
    lines.append(f'\t\t\t\tASSTECATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
    lines.append(f'\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    lines.append(f'\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    lines.append(f'\t\t\t\tDEVELOPMENT_ASSET_PATHS = "";')
    lines.append(f'\t\t\t\tENABLE_PREVIEWS = YES;')
    lines.append(f'\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
    lines.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
    lines.append(f'\t\t\t\tLE_SWIFT_VERSION = 5.0;')
    lines.append(f'\t\t\t\tMARKETING_VERSION = 1.0;')
    lines.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.nurseryconnect.app;')
    lines.append(f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    lines.append(f'\t\t\t\tSDKROOT = iphoneos;')
    lines.append(f'\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
    lines.append(f'\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
    lines.append(f'\t\t\t\tSWIFT_VERSION = 5.0;')
    lines.append(f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    lines.append(f'\t\t\t}};')
    lines.append(f'\t\t\tname = Debug;')
    lines.append(f'\t\t}};')

    # App target release
    lines.append(f'\t\t{CONFIGS["app_release"]} /* Release */ = {{')
    lines.append(f'\t\t\tisa = XCBuildConfiguration;')
    lines.append(f'\t\t\tbuildSettings = {{')
    lines.append(f'\t\t\t\tASSTECATALOG_COMPILER_APPICON_NAME = AppIcon;')
    lines.append(f'\t\t\t\tASSTECATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
    lines.append(f'\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    lines.append(f'\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    lines.append(f'\t\t\t\tDEVELOPMENT_ASSET_PATHS = "";')
    lines.append(f'\t\t\t\tENABLE_PREVIEWS = YES;')
    lines.append(f'\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
    lines.append(f'\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
    lines.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
    lines.append(f'\t\t\t\tLE_SWIFT_VERSION = 5.0;')
    lines.append(f'\t\t\t\tMARKETING_VERSION = 1.0;')
    lines.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.nurseryconnect.app;')
    lines.append(f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    lines.append(f'\t\t\t\tSDKROOT = iphoneos;')
    lines.append(f'\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
    lines.append(f'\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
    lines.append(f'\t\t\t\tSWIFT_VERSION = 5.0;')
    lines.append(f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    lines.append(f'\t\t\t}};')
    lines.append(f'\t\t\tname = Release;')
    lines.append(f'\t\t}};')

    # Test target debug
    lines.append(f'\t\t{CONFIGS["test_debug"]} /* Debug */ = {{')
    lines.append(f'\t\t\tisa = XCBuildConfiguration;')
    lines.append(f'\t\t\tbuildSettings = {{')
    lines.append(f'\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";')
    lines.append(f'\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    lines.append(f'\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    lines.append(f'\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    lines.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
    lines.append(f'\t\t\t\tMARKETING_VERSION = 1.0;')
    lines.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.nurseryconnect.app.tests;')
    lines.append(f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    lines.append(f'\t\t\t\tSDKROOT = iphoneos;')
    lines.append(f'\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
    lines.append(f'\t\t\t\tSWIFT_VERSION = 5.0;')
    lines.append(f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    lines.append(f'\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/NurseryConnect.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/NurseryConnect";')
    lines.append(f'\t\t\t}};')
    lines.append(f'\t\t\tname = Debug;')
    lines.append(f'\t\t}};')

    # Test target release
    lines.append(f'\t\t{CONFIGS["test_release"]} /* Release */ = {{')
    lines.append(f'\t\t\tisa = XCBuildConfiguration;')
    lines.append(f'\t\t\tbuildSettings = {{')
    lines.append(f'\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";')
    lines.append(f'\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    lines.append(f'\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    lines.append(f'\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    lines.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
    lines.append(f'\t\t\t\tMARKETING_VERSION = 1.0;')
    lines.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.nurseryconnect.app.tests;')
    lines.append(f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    lines.append(f'\t\t\t\tSDKROOT = iphoneos;')
    lines.append(f'\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
    lines.append(f'\t\t\t\tSWIFT_VERSION = 5.0;')
    lines.append(f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    lines.append(f'\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/NurseryConnect.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/NurseryConnect";')
    lines.append(f'\t\t\t}};')
    lines.append(f'\t\t\tname = Release;')
    lines.append(f'\t\t}};')

    lines.append('/* End XCBuildConfiguration section */')
    lines.append('')

    # === XCConfigurationList ===
    lines.append('/* Begin XCConfigurationList section */')
    lines.append(f'\t\t{CONFIG_LIST_PROJECT} /* Build configuration list for PBXProject "NurseryConnect" */ = {{')
    lines.append(f'\t\t\tisa = XCConfigurationList;')
    lines.append(f'\t\t\tbuildConfigurations = (')
    lines.append(f'\t\t\t\t{CONFIGS["project_debug"]} /* Debug */,')
    lines.append(f'\t\t\t\t{CONFIGS["project_release"]} /* Release */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tdefaultConfigurationIsVisible = 0;')
    lines.append(f'\t\t\tdefaultConfigurationName = Release;')
    lines.append(f'\t\t}};')

    lines.append(f'\t\t{CONFIG_LIST_APP} /* Build configuration list for PBXNativeTarget "NurseryConnect" */ = {{')
    lines.append(f'\t\t\tisa = XCConfigurationList;')
    lines.append(f'\t\t\tbuildConfigurations = (')
    lines.append(f'\t\t\t\t{CONFIGS["app_debug"]} /* Debug */,')
    lines.append(f'\t\t\t\t{CONFIGS["app_release"]} /* Release */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tdefaultConfigurationIsVisible = 0;')
    lines.append(f'\t\t\tdefaultConfigurationName = Release;')
    lines.append(f'\t\t}};')

    lines.append(f'\t\t{CONFIG_LIST_TEST} /* Build configuration list for PBXNativeTarget "NurseryConnectTests" */ = {{')
    lines.append(f'\t\t\tisa = XCConfigurationList;')
    lines.append(f'\t\t\tbuildConfigurations = (')
    lines.append(f'\t\t\t\t{CONFIGS["test_debug"]} /* Debug */,')
    lines.append(f'\t\t\t\t{CONFIGS["test_release"]} /* Release */,')
    lines.append(f'\t\t\t);')
    lines.append(f'\t\t\tdefaultConfigurationIsVisible = 0;')
    lines.append(f'\t\t\tdefaultConfigurationName = Release;')
    lines.append(f'\t\t}};')
    lines.append('/* End XCConfigurationList section */')
    lines.append('')

    lines.append('\t};')
    lines.append(f'\trootObject = {PROJECT_ID} /* Project object */;')
    lines.append('}')

    return '\n'.join(lines)


if __name__ == '__main__':
    base = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.join(base, 'NurseryConnect.xcodeproj')
    os.makedirs(proj_dir, exist_ok=True)
    pbxproj_path = os.path.join(proj_dir, 'project.pbxproj')
    content = build_pbxproj()
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    print(f'Generated: {pbxproj_path}')
