import com.ms.wfc.html.*;
import com.ms.wfc.core.*;
import com.ms.wfc.ui.*;

public class Class1 extends DhDocument 
{
	DhText createdText;
	DhText boundText;
	
	public Class1() 
	{
		// Required for Visual J++ Form Designer support
		initForm();		

		// TODO: Add any constructor code after initForm call
	}

	/**
	 * Class1 overrides dispose so it can clean up the
	 * component list.
	 */
	public void dispose() 
	{
		super.dispose();
	}

	/**
	 * Add all your initialization code here. The code here can add elements,
	 * set bindings to existing elements, set new properties and event handlers
	 * on elements. The underlying HTML document is not available at this stage,
	 * so any calls that rely on the document being present should be added to
	 * the onDocumentLoad() function below (client-only).
	 */
	private void initForm() 
	{
		createdText = new DhText();
		createdText.setText("Created Text");
                
		boundText = new DhText();
		boundText.setID("bindText");
		boundText.setBackColor(Color.LIGHTGRAY);

		/**
		 * setBoundElements() will take a list of elements that already are present
		 * in the HTML document, and binds them to the DhElement list.
		 */
		setBoundElements(new DhElement[] {boundText});

		/**
		 * setNewElements() takes a list of DhElements and adds them to the HTML document.
		 */
		setNewElements(new DhElement[] {createdText});
	}
	
	/**
	 * Client-side only.
	 * 
	 * Here, the underlying HTML document is available for inspection. Add any code 
	 * that wants to get properties of elements or inspect the document in any other way.
	 */
	protected void onDocumentLoad(Object sender, Event e) 
	{
	}
}
