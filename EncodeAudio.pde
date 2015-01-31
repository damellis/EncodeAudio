import java.awt.datatransfer.*;
import java.awt.Toolkit;
import javax.swing.JOptionPane;
import ddf.minim.*;

int SAMPLES = 30000;

Minim minim;
AudioSample sample;

void setup()
{
  size(512, 200);
  
  selectInput("Select audio file to encode.", "callback");
}
void callback(File sfile){
  String file = sfile.getAbsolutePath();
  
  if (file == null) {
    exit();
    return;
  }
  
  try {
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  
    minim = new Minim(this);
    sample = minim.loadSample(file);
    
    float[] samples = sample.getChannel(1); //BufferedAudio.LEFT
    float maxval = 0;
  
    for (int i = 0; i < samples.length; i++) {
      if (abs(samples[i]) > maxval) maxval = samples[i];
    }
    
    int start;
    
    for (start = 0; start < samples.length; start++) {
      if (abs(samples[start]) / maxval > 0.01) break;
    }
  
    String result = "";  
    for (int i = start; i < samples.length && i - start < SAMPLES; i++) {
      result += constrain(int(map(samples[i], -maxval, maxval, 0, 256)), 0, 255) + ", ";
    }
  
    clipboard.setContents(new StringSelection(result), null);
    
    JOptionPane.showMessageDialog(null, "Audio data copied to the clipboard.", "Success!", JOptionPane.INFORMATION_MESSAGE);
  } catch (Exception e) {
    JOptionPane.showMessageDialog(null, "Maybe you didn't pick a valid audio file?\n" + e, "Error!", JOptionPane.ERROR_MESSAGE);
  }
  
  exit();
  
}

void stop()
{
  sample.close();
  minim.stop();
  super.stop();
}
