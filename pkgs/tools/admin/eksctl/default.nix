{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "eksctl";
  version = "0.140.0";

  src = fetchFromGitHub {
    owner = "weaveworks";
    repo = pname;
    rev = version;
    hash = "sha256-Y7OrEbPIDnUri5LXOpyNI/fZ+Cxxxj9hTqEXGyVHwOw=";
  };

  vendorHash = "sha256-xS8MiH9ij+lKpew02pFNpYDhLRVGRzBBy3uMhyiJ0+U=";

  doCheck = false;

  subPackages = [ "cmd/eksctl" ];

  tags = [ "netgo" "release" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/weaveworks/eksctl/pkg/version.gitCommit=${src.rev}"
    "-X github.com/weaveworks/eksctl/pkg/version.buildDate=19700101-00:00:00"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd eksctl \
      --bash <($out/bin/eksctl completion bash) \
      --fish <($out/bin/eksctl completion fish) \
      --zsh  <($out/bin/eksctl completion zsh)
  '';

  meta = with lib; {
    description = "A CLI for Amazon EKS";
    homepage = "https://github.com/weaveworks/eksctl";
    license = licenses.asl20;
    maintainers = with maintainers; [ xrelkd Chili-Man ];
  };
}
