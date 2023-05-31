package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
)

// call it like: go test -v -run ^TestSuite$ -testify.m ^TestExample1$ ./suite_test.go
//               go test -v -run ^TestSuite$ -testify.m ^TestExample2$ ./suite_test.go
// run them all: go test -v -run ^TestSuite$ -testify.m ^Test ./suite_test.go

type ExampleSuite struct {
	suite.Suite
	assert *require.Assertions
}

func TestSuite(t *testing.T) {
	t.Parallel()

	suite.Run(t, new(ExampleSuite))
}

func TestMarek(t *testing.T) {
	assert.Equal(t, 1, 3)
}

// nolint dupl
func (s *ExampleSuite) SetupSuite() {
	s.assert = s.Require()
	s.T().Log("called SetupSuite")
}

func (s *ExampleSuite) TearDownSuite() {
	s.T().Log("called TearDownSuite")
}

func (s *ExampleSuite) SetupTest() {
	s.T().Log("called SetupTest")
}

func (s *ExampleSuite) TearDownTest() {
	s.T().Log("called TearDownTest")
}

func (s *ExampleSuite) TestExample1() {
	s.T().Log("called TestExample1")
	s.assert.Equal(20, Example(10, 10))
}

func (s *ExampleSuite) TestExample2() {
	s.T().Log("called TestExample2")
	s.assert.Equal(20, Example(10, 10))
}
