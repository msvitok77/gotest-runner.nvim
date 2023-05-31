package main

import "testing"

func TestExample1(t *testing.T) {
	type args struct {
		a int
		b int
	}
	tests := []struct {
		name string
		args args
		want int
	}{
		{
			name: "valid",
			args: args{
				a: 10,
				b: 10,
			},
			want: 20,
		},
	}
	for _, tt := range tests {
		tt := tt
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			if got := Example(tt.args.a, tt.args.b); got != tt.want {
				t.Errorf("Example() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestExample(t *testing.T) {
	type args struct {
		a int
		b int
	}
	tests := []struct {
		name string
		args args
		want int
	}{
		{
			name: "valid",
			args: args{
				a: 10,
				b: 10,
			},
			want: 20,
		},
	}
	for _, tt := range tests {
		tt := tt
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			if got := Example(tt.args.a, tt.args.b); got != tt.want {
				t.Errorf("Example() = %v, want %v", got, tt.want)
			}
		})
	}
}
