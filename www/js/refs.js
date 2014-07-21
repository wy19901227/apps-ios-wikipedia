var bridge = require("./bridge");

function isReference( href ) {
    return ( href.slice( 0, 10 ) === "#cite_note" );
}

function goDown( element ) {
    return element.getElementsByTagName( "A" )[0];
}

function hasReferenceLink( element ) {
    try {
        return isReference( goDown( element ).getAttribute( "href" ) );
    } catch (e) {
        return false;
    }
}

function collectRefText( sourceNode ) {
    var href = sourceNode.getAttribute( "href" );
    var targetId = href.slice(1);
    var targetNode = document.getElementById( targetId );
    if ( targetNode === null ) {
        console.log("reference target not found: " + targetId);
        return "";
    }

    // preferably without the back link
    var refTexts = targetNode.getElementsByClassName( "reference-text" );
    if ( refTexts.length > 0 ) {
        targetNode = refTexts[0];
    }

    return targetNode.innerHTML;
}

function collectRefLink( sourceNode ) {
    var node = sourceNode;
    while (!node.classList || !node.classList.contains('reference')) {
        node = node.parentNode;
        if (!node) {
            return '';
        }
    }
    return node.id;
}

function sendNearbyReferences( sourceNode ) {
    var refsIndex = 0;
    var refs = [];
    var linkId = [];
    var linkText = [];
    var curNode = sourceNode;

    // handle clicked ref:
    refs.push( collectRefText( curNode ) );
    linkId.push( collectRefLink( curNode ) );
    linkText.push( curNode.textContent );

    // go left:
    curNode = sourceNode.parentElement;
    while ( hasReferenceLink( curNode.previousSibling ) ) {
        refsIndex += 1;
        curNode = curNode.previousSibling;
        refs.unshift( collectRefText( goDown ( curNode ) ) );
        linkId.unshift( collectRefLink( curNode ) );
        linkText.unshift( curNode.textContent );
    }

    // go right:
    curNode = sourceNode.parentElement;
    while ( hasReferenceLink( curNode.nextSibling ) ) {
        curNode = curNode.nextSibling;
        refs.push( collectRefText( goDown ( curNode ) ) );
        linkId.push( collectRefLink( curNode ) );
        linkText.push( curNode.textContent );
    }

    // Special handling for references
    bridge.sendMessage( 'referenceClicked', {
        "refs": refs,
        "refsIndex": refsIndex,
        "linkId": linkId,
        "linkText": linkText
    } );
}

exports.isReference = isReference;
exports.sendNearbyReferences = sendNearbyReferences;
