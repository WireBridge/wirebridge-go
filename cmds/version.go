package cmds

import (
	"fmt"

	"github.com/spf13/cobra"
)

func newVersionCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print current version of utg",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Fprintf(
				cmd.OutOrStdout(),
				"%s\n%s\n%s\n%s\n%s\n",
				fmt.Sprintf("UDP2gRPC version: %s", versionInfo.Version),
				fmt.Sprintf("Build type: %s", versionInfo.BuildType),
				fmt.Sprintf("Build time: %s", versionInfo.BuildTime),
				fmt.Sprintf("Golang: %s", versionInfo.GoVersion),
				fmt.Sprintf("Compiled by: %s", versionInfo.CompiledBy),
			)
		},
	}
}
