package checksums;

import org.jruby.embed.ScriptingContainer;
import org.junit.Test;

import java.io.StringWriter;
import java.nio.file.Paths;

import static org.assertj.core.api.Assertions.assertThat;
import static org.jruby.embed.PathType.ABSOLUTE;

public class PrintDeepFilestructuresMD5Test {

    @Test
    public void shouldPrintMd5ByRubyScript() throws Exception {
        ScriptingContainer container = new ScriptingContainer();
        StringWriter stdOut = new StringWriter();
        container.setOutput(stdOut);

        String baseDir = System.getProperty("user.dir");
        String assetsPath = Paths.get(baseDir, "src", "test", "ruby", "assets")
                .toAbsolutePath()
                .toString();
        String scriptPath = Paths.get(baseDir, "src", "main", "ruby", "checksums", "PrintDeepFilestructuresMD5.rb")
                .toAbsolutePath()
                .toString();
        String[] args = {assetsPath, "*\\.txt"};
        container.setArgv(args);
        container.runScriptlet(ABSOLUTE, scriptPath);

        assertThat(stdOut.toString())
                .containsSubsequence(
                    "Found (2) files with the same MD5: 60b725f10c9c85c70d97880dfe8191b3",
                    "assets/a.txt",
                    "assets/subdir/a.txt",
                    "a.txt",
                    "MD5: 60b725f10c9c85c70d97880dfe8191b3",
                    "b.txt",
                    "MD5: ba1f2511fc30423bdbb183fe33f3dd0f",
                    "MD5: c0710d6b4f15dfa88f600b0e6b624077"
                );
    }
}
