/*:

 # Recommendations

 For each playground, set the scheme to the adaptor that playground uses

 Set execution mode to automatic

 # TroubleShooting Playgrounds: Issues

 ### error: 1.2 Dictionaries to SceneKit.xcplaygroundpage:46:25: error: extraneous argument label 'node:' in call
 ### let mySelection = select(node:scene.rootNode)

 This is caused by SceneGraph not being compiled, and lldb simply skipping it.

 Check that your Scheme is set to the correct Adaptor - probably StarJoinSceneKitAdaptor, and retry.

 Note that when xcode resets, the scheme is often re-set to the default, which might not be the one you want.

 ### error: PCH was compiled with module cache path '/var/folders/12/ftrrwtt54977v969dwdmkbhh0000gv/C/clang/ModuleCache/1YYYMQZPEYYBV', but the path is currently '/var/folders/12/ftrrwtt54977v969dwdmkbhh0000gv/C/clang/ModuleCache/KPC83QJQXY7Z'

 Unclear.  This happens to iOS playgrounds like 90% of the time for me.  I wish I knew why.

 */
