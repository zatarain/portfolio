import NavigationBar from '#components/NavigationBar';
import styles from './index.module.css'

interface Properties {
	data: {
		name: string
	}
}

const Header = ({ data }: Properties) => {
	return (
		<header className={styles.header}>
			<NavigationBar name={data?.name} />
		</header>
	)
}

export default Header
