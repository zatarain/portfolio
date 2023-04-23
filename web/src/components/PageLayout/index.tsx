import Head from "next/head";
import { ReactNode } from "react";

interface Props {
	children?: ReactNode
	data: any
	title?: string
}

export default function PageLayout({ children, title, data }: Props) {
	const pageTitle = [data?.name, title].filter(part => !!part).join(' - ')
	return (
		<div className="container">
			<Head>
				<title>{pageTitle}</title>
				<link rel="icon" href="/favicon.ico" />
			</Head>
			<header>
				<nav>
					<h1>{data && data?.name}</h1>
					<menu></menu>
				</nav>
			</header>
			<main>
				{children}
			</main>
			<footer>
				<ul>
					<li>
						<h4>Products</h4>
						<ul>
							<li><a href="#">Features</a></li>
							<li><a href="#">Integrations</a></li>
							<li><a href="#">Enterprice</a></li>
							<li><a href="#">Solutions</a></li>
						</ul>
					</li>
					<li>
						<h4>Products</h4>
						<ul>
							<li><a href="#">Features</a></li>
							<li><a href="#">Integrations</a></li>
							<li><a href="#">Enterprice</a></li>
							<li><a href="#">Solutions</a></li>
						</ul>
					</li>
					<li>
						<h4>Products</h4>
						<ul>
							<li><a href="#">Features</a></li>
							<li><a href="#">Integrations</a></li>
							<li><a href="#">Enterprice</a></li>
							<li><a href="#">Solutions</a></li>
						</ul>
					</li>
					<li>
						<h4>Resources</h4>
						<ul>
							<li><a href="#">Partners</a></li>
							<li><a href="#">Developers</a></li>
							<li><a href="#">Community</a></li>
							<li><a href="#">Apps</a></li>
						</ul>
					</li>
					<li>
						<h4>Company</h4>
						<ul>
							<li><a href="#">About us</a></li>
							<li><a href="#">Leadership</a></li>
						</ul>
					</li>
				</ul>
			</footer>
		</div>
	)
}
