# StarJoinSpriteKitAdaptor

A description of this package.

# TroubleShooting Playgrounds: Issues

### error: 1.2 Dictionaries to SceneKit.xcplaygroundpage:46:25: error: extraneous argument label 'node:' in call
### let mySelection = select(node:scene.rootNode)

This is caused by SceneGraph not being compiled, and lldb simply skipping it.

Check that your Scheme is set to the correct Adaptor - probably StarJoinSceneKitAdaptor, and retry.

Note that when xcode resets, the scheme is often re-set to the default, which might not be the one you want.

