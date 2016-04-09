package config

type UnikConfig struct {
	Config Config `yaml:"config"`
}

type Config struct {
	Providers Providers `yaml:"providers"`
}
type Providers struct {
	Aws     []Aws     `yaml:"aws"`
	Vsphere []Vsphere `yaml:"vsphere"`
	Vbox    []Vbox    `yaml:"vbox"`
}

type Aws struct {
	Name              string `yaml:"name"`
	AwsAccessKeyID    string `yaml:"aws_access_key_id"`
	AwsSecretAcessKey string `yaml:"aws_secret_acess_key"`
	Region            string `yaml:"region"`
	Zone              string `yaml:"zone"`
}

type Vsphere struct {
	Name            string `yaml:"name"`
	VsphereUser     string `yaml:"vsphere_user"`
	VspherePassword string `yaml:"vsphere_password"`
	VsphereURL      string `yaml:"vsphere_url"`
}

type Vbox struct {
	Name              string `yaml:"name"`
	SomethingGoesHere string `yaml:"something"`
}